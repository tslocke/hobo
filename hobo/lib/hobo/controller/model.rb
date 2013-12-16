module Hobo
  module Controller
    module Model

    include Hobo::Controller

    DONT_PAGINATE_FORMATS = [ Mime::CSV, Mime::YAML, Mime::JSON, Mime::XML, Mime::ATOM, Mime::RSS ]

    WILL_PAGINATE_OPTIONS = [ :page, :per_page, :total_entries, :count, :finder ]

    READ_ONLY_ACTIONS  = [:index, :show]
    WRITE_ONLY_ACTIONS = [:create, :update, :destroy]
    FORM_ACTIONS       = [:new, :edit]

    class << self

      def included(base)
        base.class_eval do
          @auto_actions ||= {}

          inheriting_cattr_reader :web_methods => [], :show_actions => [], :index_actions => [],
                                  :owner_actions => {}

          extend ClassMethods


          helper_method :model, :current_user
          before_filter :set_no_cache_headers

          rescue_from ActiveRecord::RecordNotFound, :with => :not_found unless Rails.env.development?

          rescue_from Hobo::PermissionDeniedError,         :with => :permission_denied
          rescue_from Hobo::Model::Lifecycles::LifecycleKeyError, :with => :permission_denied

          respond_to :html

          alias_method_chain :render, :hobo_model

        end
        register_controller(base)
        subsite = base.name.include?("::") ? base.name.split("::").first.underscore : nil
        base.model.hobo_controller[subsite] = base

        Hobo::Controller.included_in_class(base)
      end

    end


    def self.register_controller(controller)
      @controller_names ||= Set.new
      @controller_names << controller.name
    end


    def self.all_controllers(subsite=nil, force=false)
      controller_dirs = ["#{Rails.root}/app/controllers"] + Hobo.engines.map { |e| "#{e}/app/controllers" }

      # Load every controller in app/controllers/<subsite>...
      @controllers_loaded ||= {}
      if force || !@controllers_loaded[subsite]
        controller_dirs.each do |controller_dir|
          dir = "#{controller_dir}#{'/' + subsite if subsite}"
          if File.directory?(dir)
            Dir.entries(dir).each do |f|
              if f =~ /^[a-zA-Z_][a-zA-Z0-9_]*_controller\.rb$/
                name = f.remove(/.rb$/).camelize
                name = "#{subsite.camelize}::#{name}" if subsite
                name.constantize
              end
            end
          end
        end
        @controllers_loaded[subsite] = true
      end

      # ...but only return the ones that registered themselves
      names = (@controller_names || []).select { |n| subsite ? n =~ /^#{subsite.camelize}::/ : n !~ /::/ }

      names.map do |name|
        name.safe_constantize || (@controller_names.delete name; nil)
      end.compact
    end


    module ClassMethods

      attr_writer :model

      def model_name
        model.name.underscore
      end

      def model
        @model ||= controller_name.camelcase.singularize.constantize
      end


      def autocomplete(*args, &block)
        options = args.extract_options!
        name = args.first || model.name_attribute
        field = options.delete(:field) || name
        if block
          index_action "complete_#{name}", &block
        else
          index_action "complete_#{name}" do
            hobo_completions field, model, options
          end
        end
      end


      def web_method(web_name, options={}, &block)
        web_methods << web_name.to_sym
        method = options.delete(:method) || web_name
        got_block = block_given?
        define_method web_name do
          # Make sure we have a copy of the options - it is being mutated somewhere
          opts = options.dup
          self.this = find_instance(opts)
          raise Hobo::PermissionDeniedError unless @this.method_callable_by?(current_user, method)
          if got_block
            this.with_acting_user(current_user) { instance_eval(&block) }
          else
            @this.send(method)
          end

          hobo_ajax_response unless performed?
        end
      end


      def auto_actions(*args)
        options = args.extract_options!

        @auto_actions = args.map do |arg|
                          case arg
                          when :all        then available_auto_actions
                          when :write_only then available_auto_write_actions
                          when :read_only  then available_auto_read_actions
                          when :lifecycle  then available_auto_lifecycle_actions
                          else arg
                          end
                        end.flatten.uniq

        except = Array(options[:except])
        except_actions = except.map do |arg|
          case arg
            when :lifecycle   then available_auto_lifecycle_actions
            else arg
          end
        end.flatten.uniq

        @auto_actions -= except_actions

        def_auto_actions
      end


      def def_auto_actions
        self.class_eval do
          def index;   hobo_index   end if include_action?(:index)
          def show;    hobo_show    end if include_action?(:show)
          def new;     hobo_new     end if include_action?(:new)
          def create;  hobo_create  end if include_action?(:create)
          def edit;    hobo_show    end if include_action?(:edit)
          def update;  hobo_update  end if include_action?(:update)
          def destroy; hobo_destroy end if include_action?(:destroy)

          def completions; hobo_completions end if include_action?(:completions)

          def reorder; hobo_reorder end if include_action?(:reorder)
        end

        def_lifecycle_actions
      end


      def def_auto_action(name, &block)
        define_method name, &block if !method_defined?(name) && include_action?(name)
      end


      def def_lifecycle_actions
        if model.has_lifecycle?
          model::Lifecycle.publishable_creators.each do |creator|
            name = creator.name
            def_auto_action name do
              creator_page_action name
            end
            def_auto_action "do_#{name}" do
              do_creator_action name
            end
          end

          model::Lifecycle.publishable_transitions.each do |transition|
            name = transition.name
            def_auto_action name do
              transition_page_action name
            end
            def_auto_action "do_#{name}" do
              do_transition_action name
            end
          end
        end
      end


      def show_action(*names, &block)
        options = names.extract_options!
        show_actions.concat(names)
        for name in names
          if block
            define_method(name, &block)
          else
            define_method(name) { hobo_show options.dup }
          end
        end
      end


      def index_action(*names, &block)
        options = names.extract_options!
        index_actions.concat(names)
        for name in names
          if block
            define_method(name, &block)
          else
            if scope = options.delete(:scope)
              if scope.is_a?(Symbol)
                define_method(name) { hobo_index model.send(scope), options.dup }
              else
                define_method(name) { hobo_index scope, options.dup }
              end
            else
              define_method(name) { hobo_index options.dup }
            end
          end
        end
      end


      def creator_page_action(name, options={}, &block)
        define_method(name) do
          creator_page_action name, options, &block
        end
      end


      def do_creator_action(name, options={}, &block)
        define_method("do_#{name}") do
          do_creator_action name, options, &block
        end
      end


      def transtion_page_action(name, options={}, &block)
        define_method(name) do
          transtion_page_action name, options, &block
        end
      end


      def do_transition_action(name, options={}, &block)
        define_method("do_#{name}") do
          do_transition_action name, options, &block
        end
      end


      def auto_actions_for(owner, actions)
        name = model.reflections[owner].macro == :has_many ? owner.to_s.singularize : owner

        owner_actions[owner] ||= []
        Array(actions).each do |action|
          case action
          when :new
            define_method("new_for_#{name}")    { hobo_new_for owner }
          when :index
            define_method("index_for_#{name}")  { hobo_index_for owner }
          when :create
            define_method("create_for_#{name}") { hobo_create_for owner }
          else
            raise ArgumentError, "Invalid owner action: #{action}"
          end
          owner_actions[owner] << action
        end
      end


      def include_action?(name)
        name.to_sym.in?(@auto_actions)
      end


      def available_auto_actions
        (available_auto_read_actions +
         available_auto_write_actions +
         FORM_ACTIONS +
         available_auto_lifecycle_actions).uniq
      end


      def available_auto_read_actions
        READ_ONLY_ACTIONS
      end


      def available_auto_write_actions
        if model.method_defined?("position_column")
          WRITE_ONLY_ACTIONS + [:reorder]
        else
          WRITE_ONLY_ACTIONS
        end
      end


      def available_auto_lifecycle_actions
        # For each creator/transition there are two possible
        # actions. e.g. for signup, 'signup' would be routed to
        # GET users/signup, and would show the form, while 'do_signup'
        # would be routed to POST /users/signup)
        if model.has_lifecycle?
          (model::Lifecycle.publishable_creators.map { |c| [c.name, "do_#{c.name}"] } +
           model::Lifecycle.publishable_transitions.map { |t| [t.name, "do_#{t.name}"] }).flatten.*.to_sym
        else
          []
        end
      end

    end # of ClassMethods


    protected


    def parse_sort_param(*args)
      _, desc, field = *params[:sort]._?.match(/^(-)?([a-z_]+(?:\.[a-z_]+)?)$/)

      if field
        hash = args.extract_options!
        db_sort_field = (hash[field] || hash[field.to_sym] || (field if field.in?(args) || field.to_sym.in?(args))).to_s

        unless db_sort_field.blank?
          if db_sort_field == field && field.match(/\./)
            fields = field.split(".", 2)
            db_sort_field = "#{fields[0].pluralize}.#{fields[1]}"
          end
          @sort_field = field
          @sort_direction = desc ? "desc" : "asc"

          "#{db_sort_field} #{@sort_direction}"
        end
      end
    end

    # --- Action implementation helpers --- #


    def find_instance(options={})
      model.user_find(current_user, params[:id], options) do |record|
        yield record if block_given?
      end
    end


    def invalid?; !valid?; end


    def valid?; this.errors.empty?; end


    def re_render_form(default_action=nil)
      if params[:page_path]
        @invalid_record = this
        controller, action = controller_action_from_page_path

        # Hack fix for Bug 477.  See also bug 489.
        if self.class.name == "#{controller.camelize}Controller" && action == "index"
          params['action'] = 'index'
          self.action_name = 'index'
	  self.this = find_or_paginate(model, {})
          index
        else
          render :template => "#{controller}/#{action}"
        end
      else
        render :action => default_action
      end
    end


    def destination_after_submit(*args)
      options = args.extract_options!
      destroyed = args[1]
      after_submit = params[:after_submit]

      # The after_submit post parameter takes priority
      (after_submit == "stay-here" ? url_for_page_path : after_submit) ||

        # Then try options[:redirect]
        ((o=options[:redirect]) && begin
                                     if o.is_a?(Symbol)
                                       object_url(@this, o)
                                     elsif o.is_a?(String) || o.is_a?(Hash)
                                       o
                                     else
                                       object_url(*Array(o))
                                     end
                                   end) ||

        # Then try the record's show page
        (!destroyed && !@this.new_record? && object_url(@this)) ||

        # Then the show page of the 'owning' object if there is one
        object_url(owning_object) ||

        # Last try - the index page for this model
        object_url(@this.class) ||

        # Give up
        home_page
    end

    def owning_object
      method = @this.class.view_hints.parent
      method ? @this.send(method) : nil
    end


    def response_block(&b)
      if b
        if b.arity == 1
          respond_to do |format|
            yield format
          end
        else
          yield
        end
        performed?
      end
    end


    def request_requires_pagination?
      request.format.not_in?(DONT_PAGINATE_FORMATS) && model.view_hints.paginate?
    end


    def find_or_paginate(finder, options)
      options = options.reverse_merge(:paginate => request_requires_pagination?)
      do_pagination = options.delete(:paginate) && finder.respond_to?(:paginate)
      finder = Array.wrap(options.delete(:scope)).inject(finder) { |a, v| a.send(*Array.wrap(v).flatten) }

      options[:order] = finder.default_order unless options[:order] || finder.try.order_values.present?

      if do_pagination
        options.reverse_merge!(:page => params[:page] || 1)
        finder.paginate(options)
      else
        finder.all(options.except(*WILL_PAGINATE_OPTIONS))
      end
    end


    def find_owner_and_association(owner_association)
      owner_name = name_of_auto_action_for(owner_association)
      refl = model.reflections[owner_association]
      id = params["#{owner_name}_id"]
      owner = refl.klass.find(id)
      instance_variable_set("@#{owner_association}", owner)
      [owner, owner.send(model.reverse_reflection(owner_association).name)]
    end

    def name_of_auto_action_for(owner_association)
      model.reflections[owner_association].macro == :has_many ? owner_association.to_s.singularize : owner_association
    end

    # --- Action implementations --- #

    def hobo_index(*args, &b)
      options = args.extract_options!
      finder = args.first || model
      self.this ||= find_or_paginate(finder, options)
      response_block(&b) || index_response
    end


    def hobo_index_for(owner, *args, &b)
      options = args.extract_options!
      owner, association = find_owner_and_association(owner)
      finder = args.first || association
      self.this ||= find_or_paginate(finder, options)
      response_block(&b) || index_response
    end


    def hobo_show(*args, &b)
      options = args.extract_options!
      self.this ||= args.first
      if this.nil?
        self.this = find_instance(options)
        unless (parms=attribute_parameters).blank?
          this.with_acting_user(current_user) { this.attributes = parms }
        end
      end
      response_block(&b) || show_response
    end

    def hobo_edit(*args, &b)
      hobo_show(*args, &b)
    end

    def hobo_new(record=nil, &b)
      self.this ||= record || model.user_new(current_user, attribute_parameters)
      response_block(&b) || show_response
    end

    def show_response
      if request.xhr? && params[:render]
        hobo_ajax_response
        render :nothing => true unless performed?
      else
        respond_with(self.this)
      end
    end

    def index_response
      if request.xhr? && params[:render]
        hobo_ajax_response(:page => :blah)
        render :nothing => true unless performed?
      else
        respond_with(self.this)
      end
    end

    def hobo_new_for(owner, record=nil, &b)
      owner, association = find_owner_and_association(owner)
      self.this ||= record || association.user_new(current_user, attribute_parameters)
      response_block(&b) || show_response
    end


    def hobo_create(*args, &b)
      options = args.extract_options!
      attributes = options[:attributes] || attribute_parameters || {}
      if self.this ||= args.first
        this.user_update_attributes(current_user, attributes)
      else
        self.this = new_for_create(attributes)
        this.user_save(current_user)
      end
      flash_notice (ht( :"#{@this.class.to_s.underscore}.messages.create.success", :default=>["The #{@this.class.model_name.human} was created successfully"])) if valid?
      response_block(&b) || create_response(:new, options)
    end


    def hobo_create_for(owner_association, *args, &b)
      options = args.extract_options!
      owner, association = find_owner_and_association(owner_association)
      attributes = options[:attributes] || attribute_parameters || {}
      if self.this ||= args.first
        this.user_update_attributes(current_user, attributes)
      else
        self.this = association.new(attributes)
        this.save
      end
      flash_notice (ht( :"#{@this.class.to_s.underscore}.messages.create.success", :default=>["The #{@this.class.model_name.human} was created successfully"])) if valid?
      response_block(&b) || create_response(:"new_for_#{name_of_auto_action_for(owner_association)}", options)
    end


    def attribute_parameters
      params[(this ? this.class : model).name.underscore]
    end


    def new_for_create(attributes = {})
      type_param = subtype_for_create
      create_model = type_param ? type_param.constantize : model
      create_model.user_new(current_user, attributes)
    end


    def subtype_for_create
      model.has_inheritance_column? && (t = params['type']) && t.in?(model.send(:descendants).*.name) and
        t
    end

    def flash_notice(message)
      flash[:notice] = message unless request.xhr?
    end


    def create_response(new_action=:new, options={})
      valid = valid?  # valid? can be expensive
      if params[:render]
        if (params[:render_options] && params[:render_options][:errors_ok]) || valid
          hobo_ajax_response

          # Maybe no ajax requests were made
          render :nothing => true unless performed?
        else
          errors = @this.errors.full_messages.join('\n')
          message = ht( :"#{this.class.to_s.underscore}.messages.create.error", :errors=>errors,:default=>["Couldn't create the #{this.class.name.titleize.downcase}.\n #{errors}"])
          render :js => "alert(#{message.to_json});\n"
        end
      else
        location = destination_after_submit(options)
        respond_with(self.this, :location => location) do |format|
          format.html do
            if valid
              redirect_to location
            else
              re_render_form(new_action)
            end
          end
        end
      end
    end


    def hobo_update(*args, &b)
      options = args.extract_options!

      self.this ||= args.first || find_instance
      changes = options[:attributes] || attribute_parameters or raise RuntimeError, t("hobo.messages.update.no_attribute_error", :default=>["No update specified in params"])

      if this.user_update_attributes(current_user, changes)
        # Ensure current_user isn't out of date
        @current_user = @this if @this == current_user
      end

      response_block(&b) ||  update_response(nil, options)
    end


    # typically used like this:
    # def update
    #   hobo_update do
    #     if params[:foo]==17
    #       render_my_way
    #     else
    #       update_response   # let Hobo handle it all
    #     end
    #   end
    # end
    #
    # parameters:
    #   valid is a cache of valid?
    #   options is passed through to destination_after_submit
    def update_response(valid=nil, options={})
      # valid? can be expensive, cache it
      valid = valid? if valid.nil?
      if params[:render]
        if (params[:render_options] && params[:render_options][:errors_ok]) || valid
          hobo_ajax_response

          # Maybe no ajax requests were made
          render :nothing => true unless performed?
        else
          errors = @this.errors.full_messages.join('\n')
          message = ht(:"#{@this.class.to_s.underscore}.messages.update.error", :default=>["There was a problem with that change\\n#{errors}"], :errors=>errors)

          render :js => "alert(#{message.to_json});\n"
        end
      else
        location = destination_after_submit(options)
        respond_with(self.this, :location => location) do |format|
          format.html do
            if valid
              flash_notice (ht(:"#{@this.class.to_s.underscore}.messages.update.success", :default=>["Changes to the #{@this.class.model_name.human} were saved"]))
              redirect_to location
            else
              re_render_form(:edit)
            end
          end
        end
      end
    end

    def hobo_destroy(*args, &b)
      options = args.extract_options!
      self.this ||= args.first || find_instance
      this.user_destroy(current_user)
      flash_notice ht( :"#{model.to_s.underscore}.messages.destroy.success", :default=>["The #{model.name.titleize.downcase} was deleted"])
      response_block(&b) || destroy_response(options, &b)
    end


    def destroy_response(options={})
      if params[:render]
        hobo_ajax_response || render(:nothing => true)
      else
        redirect_to destination_after_submit(this, true, options)
      end
    end


    # --- Lifecycle Actions --- #

    def creator_page_action(name, options={}, &b)
      self.this ||= model.new
      this.exempt_from_edit_checks = true
      @creator = model::Lifecycle.creator(name)
      raise Hobo::PermissionDeniedError unless @creator.allowed?(current_user)
      response_block &b
    end


    def do_creator_action(name, options={}, &b)
      @creator = model::Lifecycle.creator(name)
      self.this = @creator.run!(current_user, attribute_parameters)
      response_block(&b) || do_creator_response(name, options)
    end

    def do_creator_response(name, options)
      if valid?
        if params[:render]
          hobo_ajax_response || render(:nothing => true)
        else
          location = destination_after_submit(options)
          respond_with(self.this, :location => location)
        end
      else
        this.exempt_from_edit_checks = true
        if params[:render] && params[:render_options] && params[:render_options][:errors_ok]
          hobo_ajax_response
          render :nothing => true unless performed?
        else
          # errors is used by the translation helper, ht, below.
          errors = this.errors.full_messages.join("\n")
          respond_with(self.this) do |wants|
            wants.html { re_render_form(name) }
          end
        end
      end
    end

    def prepare_transition(name, options)
      key = options.delete(:key) || params[:key]

      # we don't use find_instance here, as it fails for key_holder transitions on objects that Guest can't view
      record = model.find(params[:id])
      record.exempt_from_edit_checks = true
      record.lifecycle.provided_key = key
      self.this = record

      this.lifecycle.find_transition(name, current_user) or raise Hobo::PermissionDeniedError
    end


    def transition_page_action(name, options={}, &b)
      @transition = prepare_transition(name, options)
      response_block &b
    end


    def do_transition_action(name, *args, &b)
      options = args.extract_options!
      @transition = prepare_transition(name, options)
      @transition.run!(this, current_user, attribute_parameters)
      response_block(&b) || update_response(nil, options)
    end

    # --- Miscelaneous Actions --- #

    # Hobo 1.3's name one uses params[:query], jQuery-UI's autocomplete
    # uses params[:term] and jQuery Tokeninput uses params[:q]
    def hobo_completions(attribute, finder, options={})
      options = options.reverse_merge(:limit => 10, :query_scope => "#{attribute}_contains")
      options[:param] ||= [:term, :q, :query].find{|k| !params[k].nil?}
      finder = finder.limit(options[:limit]) unless finder.try.limit_value

      begin
        finder = finder.send(options[:query_scope], params[options[:param]])
        items = finder.select { |r| r.viewable_by?(current_user) }
      rescue TypeError  # must be a list of methods instead
        items = []
        options[:query_scope].each do |qscope|
          finder2 = finder.send(qscope, params[options[:param]])
          items += finder2.all.select { |r| r.viewable_by?(current_user) }
        end
      end
      if request.xhr?
        if options[:param] == :q
          render :json => items.map {|i| {:id => "@#{i.send(i.class.primary_key)}", :name => i.send(attribute)}}
        else
          render :json => items.map {|i| i.send(attribute)}
        end
      else
        render :text => "<ul>\n" + items.map {|i| "<li>#{i.send(attribute)}</li>\n"}.join + "</ul>"
      end
    end


    def hobo_reorder
      ordering = params["#{model.name.underscore}_ordering"]
      if ordering
        ordering.each_with_index do |id, position|
          object = model.find(id)
          object.user_update_attributes!(current_user, object.position_column => position+1)
        end
        hobo_ajax_response || render(:nothing => true)
      else
        render :nothing => true
      end
    end



    # --- Response helpers --- #

    def permission_denied(error)
      self.this = true # Otherwise this gets sent user_view
      logger.info "Hobo: Permission Denied!"
      @permission_error = error
      if self.class.superclass.method_defined?("permission_denied")
        super
      else
        respond_to do |wants|
          wants.html do
            if render :permission_denied, :status => 403
              # job done
            else
              render :text => t("hobo.messages.permission_denied", :default=>["Permission Denied"]), :status => 403
            end
          end
          wants.js do
            render :text => t("hobo.messages.permission_denied", :default=>["Permission Denied"]), :status => 403
          end
        end
      end
    end


    def this
      @this ||= (instance_variable_get("@#{model.name.demodulize.underscore}") ||
                 instance_variable_get("@#{model.name.demodulize.underscore.pluralize}"))
    end


    def this=(object)
      ivar = if object.is_a?(Array) || object.respond_to?(:member_class)
               (object.try.member_class || model).name.demodulize.underscore.pluralize
             else
               object.class.name.demodulize.underscore
             end
      @this = instance_variable_set("@#{ivar}", object)
    end


    def dryml_context
      this
    end


    def render_with_hobo_model(*args, &block)
      options = args.extract_options!
      self.this = options[:object] if options[:object]
      # this causes more problems than it solves, and Tom says it's not supposed to be here
      # this.user_view(current_user) if this && this.respond_to?(:user_view)
      render_without_hobo_model(*args + [options], &block)
    end

    # --- filters --- #

    def set_no_cache_headers
      headers["Pragma"] = "no-cache"
      #headers["Cache-Control"] = ["must-revalidate", "no-cache", "no-store"]
      #headers["Cache-Control"] = "no-cache"
      headers["Cache-Control"] = "no-store"
      headers["Expires"] ='0'
    end

    # --- end filters --- #

    public

    def model
      self.class.model
    end

  end
  end
end
