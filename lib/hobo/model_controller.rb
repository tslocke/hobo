module Hobo

  module ModelController

    include Hobo::Controller

    class PermissionDeniedError < RuntimeError; end

    VIEWLIB_DIR = "taglibs"
    
    GENERIC_PAGE_TAGS = [:index, :show, :new, :edit, :show_collection, :new_in_collection]

    class << self

      def included(base)
        base.extend(ClassMethods)
        base.helper_method(:find_partial, :model, :current_user)

        for collection in base.collections
          add_collection_actions(base, collection.to_sym)
        end

        base.before_filter :set_no_cache_headers
        
        Hobo::Controller.included_in_class(base)
      end

      def find_partial(klass, as)
        find_model_template(klass, as, true)
      end


      def template_path(dir, name, is_partial)
        fileRx = is_partial ? /^_#{name}\.[^.]+/ : /^#{name}\.[^.]+/
        full_dir = "#{RAILS_ROOT}/app/views/#{dir}"
        unless !File.exists?(full_dir) || Dir.entries(full_dir).grep(fileRx).empty?
          return "#{dir}/#{name}"
        end
      end


      def find_model_template(klass, name, is_partial=false)
        while klass and klass != ActiveRecord::Base
          dir = klass.name.underscore.pluralize
          path = template_path(dir, name, is_partial)
          return path if path

          klass = klass.superclass
        end
        nil
      end
      
      
      def add_collection_actions(controller_class, name)
        defined_methods = controller_class.instance_methods
        
        show_collection_method = "show_#{name}".to_sym
        unless show_collection_method.in?(defined_methods)
          controller_class.send(:define_method, show_collection_method) do
            hobo_show_collection(name)
          end  
        end
          
        if Hobo.simple_has_many_association?(controller_class.model.reflections[name])
          new_method = "new_#{name.to_s.singularize}"
          if new_method.not_in?(defined_methods)
            controller_class.send(:define_method, new_method) do
              hobo_new_in_collection(name)
            end
          end
        end
      end
      
    end

    module ClassMethods

      attr_writer :model
      
      def web_methods
        @web_methods ||= superclass.respond_to?(:web_methods) ? superclass.web_methods : []
      end
      
      def show_actions
        @show_actions ||= superclass.respond_to?(:show_actions) ? superclass.show_actions : []
      end
      
      def collections
        # By default, all has_many associations are published
        @collections ||= if superclass.respond_to?(:collections)
                           superclass.collections
                         else
                           model.reflections.values.map {|r| r.name if r.macro == :has_many}.compact
                         end
      end

      def model
        @model ||= name.sub(/Controller$/, "").singularize.constantize
      end


      def autocomplete_for(attr, options={})
        opts = { :limit => 15 }.update(options)
        @completers ||= {}
        @completers[attr.to_sym] = opts
      end


      def autocompleter(name)
        (@completers && @completers[name]) ||
          (superclass.respond_to?(:autocompleter) && superclass.autocompleter(name))
      end


      def def_data_filter(name, &b)
        @data_filters ||= {}
        @data_filters[name] = b
      end
      
      
      def web_method(web_name, method_name=nil)
        method_name ||= web_name
        web_methods << web_name.to_sym
        before_filter(:only => [web_name]) {|controller| controller.send(:prepare_web_method, method_name)}
      end
      
      
      def show_action(*names)
        show_actions.concat(names)
        for name in names
          class_eval "def #{name}; hobo_show; end"
        end
      end
      
      
      def publish_collection(*names)
        collections.concat(names)
        names.each {|n| ModelController.add_collection_actions(self, n)}
      end
      
      
      def data_filter(name)
        (@data_filters && @data_filters[name]) ||
          (superclass.respond_to?(:data_filter) && superclass.data_filter(name))
      end


      def find_instance(id)
        if model.id_name? and id !~ /^\d+$/
          model.find_by_id_name(id)
        else
          model.find(id)
        end
      end

    end

    # --- ACTIONS --- #

    def index;   hobo_index; end
    def show;    hobo_show; end
    def new;     hobo_new; end
    def create;  hobo_create; end
    def edit;    hobo_edit; end
    def update;  hobo_update; end
    def destroy; hobo_destroy; end
    
    def completions
      attr = params[:for]
      opts = attr && self.class.autocompleter(attr.to_sym)
      if opts
        q = params[:query]
        items = find_with_data_filter(opts) { send("#{attr}_contains", q) }

        render :text => "<ul>\n" + items.map {|i| "<li>#{i.send(attr)}</li>\n"}.join + "</ul>"
      else
        render :text => "No completer for #{attr}", :status => 404
      end
    end


    ###### END OF ACTIONS ######

    protected
    
    def overridable_response(options, key)
      if options.has_key?(key)
        options[key]
        true
      else
        yield if block_given?
        false
      end
    end
    
    # --- action implementations --- #
    
    def hobo_index(options = {})
      options = LazyHash.new(options)
      @model = model
      @this = options[:collection] || paginated_find(options)

      instance_variable_set("@#{@model.name.pluralize.underscore}", @this)
      if block_given?
        yield
      else
        hobo_render
      end
    end
    

    def paginated_find(*args, &b)
      options = extract_options_from_args!(args)
      
      total_number = options.delete(:total_number)
      @association = options.delete(:association) or
        if args.any?
          owner, collection_name = args
          @association = collection_name.to_s.split(".").inject(owner) { |m, name| m.send(name) }
        end
        
      if @association
        total_number ||= @association.count
        @reflection = @association.proxy_reflection if @association.respond_to?(:proxy_reflection)
      end
      
      total_number ||= count_with_data_filter
      page_size = options.delete(:page_size) || 20
      page = options.delete(:page) || params[:page]
      @pages = ::ActionController::Pagination::Paginator.new(self, total_number, page_size, page)

      options = {
        :limit  => @pages.items_per_page,
        :offset => @pages.current.offset,
      }.merge(options)
      
      if @association
        @association.find(:all, options, &b)
      else
        options[:order] ||= :default
        find_with_data_filter(options, &b)
      end
    end
    
    
    def find_instance_or_not_found(options, this_option)
      x = begin
            options[this_option] || find_instance
          rescue ActiveRecord::RecordNotFound
            nil
          end
      
      not_found unless x
      x
    end
    
    
    def hobo_show(options={})
      options = LazyHash.new(options)
      
      @this = find_instance_or_not_found(options, :this)
      if @this
        if Hobo.can_view?(current_user, @this)
          set_named_this!
          yield if block_given?
          hobo_render unless performed?
        else
          permission_denied(options)
        end
      end
    end


    def hobo_new(options={})
      options = LazyHash.new(options)
      @this = options[:this] || model.new
      @this.set_creator(current_user) unless options.has_key?(:set_creator) && !options[:set_creator]
      
      if Hobo.can_create?(current_user, @this)
        set_named_this!
        yield if block_given?
        hobo_render unless performed?
      else
        permission_denied(options)
      end
    end
    

    def hobo_create(options={})
      options = LazyHash.new(options)
      
      if (@this = options[:this])
        permission_denied(options) and return unless Hobo.can_create?(current_user, @this)
      else
        attributes = params[model.name.underscore]
        type_attr = params['type']
        create_model = if 'type'.in?(model.column_names) and 
                           type_attr and type_attr.in?(model.send(:subclasses).every(:name))
                         type_attr.constantize
                       else
                         model
                       end
        @this = create_model.new
        @check_create_permission = [@this]
        initialize_from_params(@this, attributes)
        for obj in @check_create_permission
          permission_denied(options) and return unless Hobo.can_create?(current_user, obj)
        end
        @check_create_permission = nil
      end
      
      set_named_this!
      if @this.save
        if block_given?
          yield 
        else
          respond_to do |wants|
            wants.html { overridable_response(options, :html_response)  || redirect_to(object_url(@this)) }
            wants.js   { overridable_response(options, :js_response) || hobo_ajax_response || render(:text => "") }
          end
        end
      else
        # Validation errors
        unless options[:invalid_response]
          respond_to do |wants|
            wants.html { overridable_response(options, :invalid_html_response) || hobo_render(:new) }
            wants.js do
              (overridable_response(options, :invalid_js_response) ||
               render(:status => 500,
                      :text => ("There was a problem creating that #{create_model.name}.\n" +
                                @this.errors.full_messages.join("\n"))))
            end
          end
        end
      end
    end
    
    def hobo_edit(options={})
      hobo_show(options)
    end    
    
    
    def hobo_update(options={})
      options = LazyHash.new(options)
      
      @this = find_instance_or_not_found(options, :this)
      return unless @this
      
      original = @this.duplicate
      
      changes = params[model.name.underscore]
      
      if changes
        # The 'duplicate' call above can set these, but they can
        # conflict with the changes so we clear them
        @this.send(:clear_aggregation_cache)
        @this.send(:clear_association_cache)
        
        update_with_params(@this, changes)
        permission_denied(options) and return unless Hobo.can_update?(current_user, original, @this)
      end
      
      set_named_this!
      if changes.nil? || @this.save
        # Ensure current_user isn't out of date
        @current_user = @this if @this == current_user
        
        if block_given?
          yield
        else
          respond_to do |wants|
            wants.html do
              overridable_response(options, :html_response) || redirect_to(object_url(@this))
            end

            wants.js do
              overridable_response(options, :js_response) do
                if changes.size == 1
                  # Decreasingly hacky support for the scriptaculous in-place-editor
                  new_val = Hobo::Dryml.render_tag(@template, "view",
                                                   :with => @this, :field => changes.keys.first,
                                                   :no_wrapper => true)
                  hobo_ajax_response(@this, :new_field_value => new_val)
                else
                  hobo_ajax_response(@this)
                end
                
                # Maybe no ajax requests were made
                render :nothing => true unless performed?
              end
            end
          end
        end
          
      else
        # Validation errors
        respond_to do |wants|
          wants.html do
            overridable_response(options, :invalid_html_response) || render(:action => :edit)
          end

          wants.js do
            overridable_response(options, :invalid_js_response) do
              render(:status => 500,
                     :text => ("There was a problem with that change.\n" +
                               @this.errors.full_messages.join("\n")))
            end
          end
        end
      end
    end
    
    
    def hobo_destroy(options={})
      options = LazyHash.new(options)
      @this = find_instance_or_not_found(options, :this)
      return unless @this
      
      set_named_this!
      permission_denied(options) and return unless Hobo.can_delete?(current_user, @this)

      @this.destroy

      if block_given?
        yield
      else
        respond_to do |wants|
          wants.html { overridable_response(options, :html_response) || redirect_to(:action => "index") }
          wants.js   { overridable_response(options, :js_response) || hobo_ajax_response || render(:text => "") }
        end
      end
    end

    def hobo_show_collection(collection, options={})
      options = LazyHash.new(options)
      
      @owner = find_instance_or_not_found(options, :owner)
      return unless @owner
      
      toplevel_collection = collection.to_s.split(".").first
      if Hobo.can_view?(current_user, @owner, toplevel_collection)
        @this = options[:collection] || @this = paginated_find(@owner, collection, options)
        
        if block_given?
          yield
        else
          hobo_render(params[:action]) or hobo_render(:show_collection, @reflection.klass)
        end
      else
        permission_denied(options)
      end
    end
    
    
    def hobo_new_in_collection(collection, options={})
      options = LazyHash.new(options)
      @owner = find_instance_or_not_found(options, :owner)
      return unless @owner
      
      permission_denied(options) and return unless Hobo.can_view?(current_user, @owner, collection)
      
      @association = options[:collection] || @owner.send(collection)
      @this = options[:this] || @association.new
      @this.set_creator(current_user) unless options.has_key?(:set_creator) && !options[:set_creator]

      permission_denied(options) and return unless Hobo.can_create?(current_user, @this)
      
      if block_given?
        yield
      else
        hobo_render("new_#{collection.to_s.singularize}") or hobo_render(:new_in_collection, @this.class)
      end
    end
    
    
    # --- end action implementations --- #

    # --- filters --- #
    
    def prepare_web_method(method)
      @this = find_instance
      permission_denied unless Hobo.can_call?(current_user, @this, method)
    end
    
    # --- end filters --- #
    

    def set_no_cache_headers
      headers["Pragma"] = "no-cache"
      #headers["Cache-Control"] = ["must-revalidate", "no-cache", "no-store"]
      #headers["Cache-Control"] = "no-cache"
      headers["Cache-Control"] = "no-store"
      headers["Expires"] ='0'
    end


    def permission_denied(options=nil)
      if options and options[:permission_denied_response]
        # do nothing (callback handled by LazyHash)
      elsif respond_to? :permission_denied_response
        permission_denied_response
      else
        render :text => "Permission Denied", :status => 403
      end
    end
    
    def not_found(options=nil)
      if options && options[:not_found_response]
        # do nothing (callback handled by LazyHash)
      elsif respond_to? :not_found_response
        not_found_response
      else
        render(:text => "Can't find #{model.name.titleize}: #{params[:id]}", :status => 404)
      end
    end

    def find_instance(id=nil)
      res = self.class.find_instance(id || params[:id])
      instance_variable_set("@#{model.name.underscore}", res)
      res
    end
    
    def set_named_this!
      instance_variable_set("@#{model.name.underscore}", @this)      
    end


    def hobo_render(page_kind = nil, page_model=nil)
      page_kind ||= params[:action].to_sym
      page_model ||= model
      
      template = Hobo::ModelController.find_model_template(page_model, page_kind)

      if template
        render :template => template
        true
      else
        if page_kind.in? GENERIC_PAGE_TAGS
          render_tag("#{page_kind.to_s.camelize}Page", :with => @this)
          true
        else
          false
        end
      end
    end


    def model
      self.class.model
    end


    def find_template
      Hobo::ModelController.find_model_template(model, params[:action])
    end


    def with_data_filter(operation, *args, &block)
      filter_param = params.keys.find &it.starts_with?("where_")
      proc = filter_param && self.class.data_filter(filter_param[6..-1].to_sym)
      if proc
        filter_args = params[filter_param]
        filter_args = [filter_args] unless filter_args.is_a? Array
        model.send(operation, *args) do
          if block
            instance_eval(&block) & instance_exec(*filter_args, &proc)
          else
            instance_exec(*filter_args, &proc)
          end
        end
      else
        if block
          model.send(operation, *args) { instance_eval(&block) }
        else
          model.send(operation, *args)
        end
      end
    end
    
    def find_with_data_filter(opts={}, &b)
      with_data_filter(:find, :all, opts, &b)
    end
    
    
    def count_with_data_filter(opts={}, &b)
      with_data_filter(:count, opts, &b)
    end
    

    def initialize_from_params(obj, params)
      update_with_params(obj, params)
      obj.set_creator(current_user)
      (@check_create_permission ||= []) << obj
      obj
    end


    def update_with_params(object, params)
      return unless params

      params.each_pair do |field,value|
        field = field.to_sym
        refl = object.class.reflections[field]
        ar_value = if refl
                     if refl.macro == :belongs_to
                       associated_record(object, refl, value)

                     elsif Hobo.simple_has_many_association?(refl) and object.new_record?
                       # only populate has_many relationships for new records. For existing
                       # records, AR updates the DB immediately, bypassing Hobo's permission check
                       if value.is_a? Array
                         value.map {|x| associated_record(object, refl, x) }
                       else
                         value.keys.every(:to_i).sort.map{|i| associated_record(object, refl, value[i.to_s]) }
                       end
                     else
                       raise HoboError.new("association #{refl.name} is not settable via parameters")
                     end
                   else
                     param_to_value(object.class.field_type(field), value)
                   end
        object.send("#{field}=".to_sym, ar_value)
      end
    end

    
    def parse_datetime(s)
      defined?(Chronic) ? Chronic.parse(s) : Time.parse(s)
    end


    def param_to_value(field_type, value)
      if field_type.nil?
        value
      elsif field_type <= Date
        if value.is_a? Hash
          Date.new(*(%w{year month day}.map{|s| value[s].to_i}))
        elsif value.is_a? String
          dt = parse_datetime(value)
          dt && dt.to_date
        end
      elsif field_type <= Time
        if value.is_a? Hash
          Time.local(*(%w{year month day hour minute}.map{|s| value[s].to_i}))
        elsif value.is_a? String
          parse_datetime(value)
        end
      elsif field_type <= TrueClass
        (value.is_a?(String) && value.strip.downcase.in?(['0', 'false']) || value.blank?) ? false : true
      else
        # primitive field
        value
      end
    end

    def associated_record(owner, refl, value)
      if value.is_a? String
        if value.starts_with?('@')
          Hobo.object_from_dom_id(value[1..-1])
        elsif refl.klass.id_name?
          refl.klass.find_by_id_name(value)
        else
          nil
        end
      else
        if refl.macro == :belongs_to
          new_from_params(refl.klass, value)
        else
          obj = owner.send(refl.name).new
          initialize_from_params(obj, value)
          obj
        end
      end
    end


    def object_from_param(param)
      Hobo.object_from_dom_id(param)
    end

  end

end
