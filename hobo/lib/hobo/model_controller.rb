module Hobo

  module ModelController

    include Hobo::Controller

    VIEWLIB_DIR = "taglibs"
    
    PAGINATE_FORMATS = [ Mime::HTML, Mime::ALL ]
    
    READ_ONLY_ACTIONS  = [:index, :show]
    WRITE_ONLY_ACTIONS = [:create, :update, :delete]
    FORM_ACTIONS       = [:new, :edit]
    
    class << self

      def included(base)
        base.class_eval do 
          @auto_actions ||= {}
          
          extend ClassMethods
          
          helper_method :model, :current_user
          before_filter :set_no_cache_headers
          
          rescue_from ActiveRecord::RecordNotFound, :with => :not_found
              
          rescue_from Hobo::Model::PermissionDeniedError, :with => :permission_denied
          
          alias_method_chain :render, :hobo_model

        end
        base.template_path_cache = {}        

        Hobo::Controller.included_in_class(base)
      end
      
    end

    module ClassMethods

      attr_writer :model
      
      attr_accessor :template_path_cache
      

      def web_methods
        @web_methods ||= superclass.respond_to?(:web_methods) ? superclass.web_methods : []
      end
      
      
      def show_actions
        @show_actions ||= superclass.respond_to?(:show_actions) ? superclass.show_actions : []
      end
      
      
      def index_actions
        @index_actions ||= superclass.respond_to?(:index_actions) ? superclass.index_actions : []
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


      def autocomplete_for(attr, options={}, &b)
        options = options.reverse_merge(:limit => 15)
        options[:data_filters_block] = b
        @completers ||= HashWithIndifferentAccess.new
        @completers[attr.to_sym] = options
      end


      def autocompleter(name)
        (@completers && @completers[name]) ||
          (superclass.respond_to?(:autocompleter) && superclass.autocompleter(name))
      end
      
      
      def web_method(web_name, options={}, &block)
        web_methods << web_name.to_sym
        method = options.delete(:method) || web_name
        got_block = block_given?
        define_method web_name do
          # Make sure we have a copy of the options - it is being mutated somewhere
          opts = {}.merge(options)
          @this = find_instance(opts) unless opts[:no_find]
          raise Hobo::Model::PermissionDeniedError unless Hobo.can_call?(current_user, @this, method)
          if got_block
            instance_eval(&block)
          else
            @this.send(method)
          end
          
          hobo_ajax_response || render(:nothing => true) unless performed?
        end
      end
      
      
      def auto_actions(*args)
        options = args.extract_options!
        
        @auto_actions = case args.first
                          when :all        then available_auto_actions
                          when :write_only then available_auto_write_actions + args.rest
                          when :read_only  then available_auto_read_actions  + args.rest
                          else args
                        end

        except = Array(options[:except])
        except_actions = except.map do |arg|
          if arg == :collections
            available_auto_collection_actions
          else
            arg
          end
        end
        
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
        end

        collections.each { |c| def_collection_actions(c.to_sym) } 
      end
      
      
      def def_collection_actions(name)
        defined_methods = instance_methods
        
        show_collection_method = name
        if show_collection_method.not_in?(defined_methods) && include_action?(show_collection_method)
          define_method show_collection_method do
            hobo_show_collection(name)
          end
        end
          
        if Hobo.simple_has_many_association?(model.reflections[name])
          new_method = "new_#{name.to_s.singularize}"
          if new_method.not_in?(defined_methods) && include_action?(new_method)
            define_method new_method do
              hobo_new_in_collection(name)
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
            define_method(name) { hobo_show options }
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
              define_method(name) { hobo_index scope, options }
            else
              define_method(name) { hobo_index options }
            end
          end
        end
      end
      
      def publish_collection(*names)
        collections.concat(names)
        names.each {|n| def_collection_actions(n)}
      end
      
      
      def include_action?(name)
        name.to_sym.in?(@auto_actions)
      end
      
      
      def available_auto_actions
        READ_ONLY_ACTIONS + WRITE_ONLY_ACTIONS + FORM_ACTIONS + available_auto_collection_actions
      end
      
      
      def available_auto_read_actions
        READ_ONLY_ACTIONS + collections
      end
      
      
      def available_auto_write_actions
        WRITE_ONLY_ACTIONS
      end
      
      
      def available_auto_collection_actions
        collections + collections.map {|c| "new_#{c.to_s.singularize}".to_sym}
      end

    end
    

    protected
    
    def data_filter(name, &b)
      @data_filters ||= HashWithIndifferentAccess.new
      @data_filters[name] = b
    end
    
    def search(*args)
      if args.first.is_a?(Class)
        model, search_string, *columns = args
      else
        model = self.model
        search_string, *columns = args
      end
      return nil if search_string.blank?
      
      model.conditions do
        words = search_string.split
        terms = words.map do |word|
          cols = columns.map do |c|
            if c.is_a?(Symbol)
              send("#{c}_contains", word)
            elsif c.is_a?(Hash)
              c.map do |k, v| 
                related = send(k)
                v = [v] unless v.is_a?(Array)
                v.map { |related_col| related.send("#{related_col}_contains", word) }
              end
            end
          end.flatten
          any?(*cols)
        end
        all?(*terms)
      end
    end
    
    attr_accessor :data_filters
    

    # --- Action implementation helpers --- #
    
    def find_instance(*args)
      options = args.extract_options!
      id = args.first || params[:id]
      
      if model.id_name? and id !~ /^\d+$/
        model.find_by_id_name(id, options)
      else
        model.find(id, options)
      end
    end
    
    
    def paginated_find(*args, &b)
      options = args.extract_options!
      filter_conditions = data_filter_conditions
      conditions_proc = if b && filter_conditions
                          proc { block(b) & block(filter_conditions) }
                        else
                          b || filter_conditions
                        end
      
      @association = options.delete(:association) ||
        if args.length == 1
          if args.first.is_a?(String, Symbol)
            @association = model.send(args.first)
          else
            @association = args.first
          end
        elsif args.length == 2
          owner, collection_name = args
          @association = owner.send(collection_name)
        end
      @reflection = @association.proxy_reflection if @association._?.respond_to?(:proxy_reflection)
      
      model_or_assoc, @member_class = if @association
                                        [@association, @association.member_class]
                                      else
                                        [model, model]
                                      end

      page_size = options.delete(:page_size) || 20
      page = options.delete(:page) || params[:page]
      
      paginate = options.fetch(:paginate, request.format.in?(PAGINATE_FORMATS))
      options.delete(:paginate)
      if paginate
        total_number = options.delete(:total_number) ||
          begin
            # If there is a conditions block, it may depend on the includes
            count_options = conditions_proc ? { :include => options[:include] } : {}
            model_or_assoc.count(count_options, &conditions_proc)
          end
        
        @pages = ::ActionController::Pagination::Paginator.new(self, total_number, page_size, page)

        options = options.reverse_merge(:limit  => @pages.items_per_page,
                                        :offset => @pages.current.offset)
      end
      
      unless options.has_key?(:order)
        _, desc, field = *params[:sort]._?.match(/^(-)?([a-z_]+(?:\.[a-z_]+)?)$/)
        if field
          @sort_field = field
          @sort_direction = desc ? "desc" : "asc"
          
          table, column = if field =~ /^(.*)\.(.*)$/
                            [$1.camelize.constantize.table_name, $2]
                          else
                            [@member_class.table_name, field]
                         end
          options[:order] = "#{table}.#{column} #{@sort_direction}"
        elsif !@association
          options[:order] = :default
        end
      end
      
      model_or_assoc.find(:all, options, &conditions_proc) 
    end


    def invalid?; !valid?; end
    
    def valid?; this.errors.empty?; end

    
    def re_render_form(default_action)
      if params[:page_path]
        controller, view = Controller.controller_and_view_for(params[:page_path])
        view = default_action if view == Dryml::EMPTY_PAGE
        render :action => view, :controller => controller
      else
        render :action => default_action
      end
    end
    
    
    def model_for(controller_name)
      "#{controller_name.camelize}Controller".constantize.model
    end
    
    
    def destination_after_submit(record=nil)
      record ||= this
      
      # The after_submit post parameter takes priority
      params[:after_submit] || 
        
        # Then try the records show page
        object_url(@this, :if_available => true) || 
        
        # Then the show page of the 'owning' object if there is one
        (@this.dependent_on.first && object_url(@this.dependent_on.first, :if_available => true)) ||
        
        # Last try - the index page for this model
        object_url(@this.class, :if_available => true) ||
        
        # Give up
        home_page
    end
    
    
    def response_block(&b)
      if b
        if b.arity == 1
          respond_to {|wants| yield(wants) }
        else
          yield
        end
        performed?
      end
    end
    
    # --- Action implementations --- #

    def hobo_index(*args, &b)
      options = LazyHash.new(args.extract_options!)
      collection = args.first

      @model = model
      self.this ||= if collection.blank?
                     paginated_find(options)
                   elsif collection.is_a?(String, Symbol)
                     paginated_find(collection, options) # a scope name
                   else
                     collection
                  end
    end
    

    def hobo_show(*args, &b)
      options = args.extract_options!  # OK so there are no options, but just to keep the API consistent :-)
      self.this ||= args.first || find_instance
      response_block(&b)
    end
    
    
    def hobo_new(*args, &b)
      options = LazyHash.new(args.extract_options!)
      self.this ||= args.first || model.new
      this.user_changes(current_user) # set_creator and permission check
      response_block(&b)
    end
    
    
    def hobo_create(*args, &b)
      options = LazyHash.new(args.extract_options!)
      
      self.this ||= args.first || new_for_create
      this.user_save_changes(current_user, options[:attributes] || attribute_parameters)
      
      create_response(&b)
    end
    
    
    def attribute_parameters
      params[@this.class.name.underscore]
    end
    

    def new_for_create
      if model.has_inheritance_column? && (type_attr = params['type']) && type_attr.in?(model.send(:subclasses).*.name)
        type_attr.constantize
      else
        model
      end.new
    end
    
    
    def create_response(&b)
      flash[:notice] = "The #{@this.class.name.titleize.downcase} was created successfully" if !request.xhr? && valid? 
      
      response_block(&b) or
        if valid?
          respond_to do |wants|
            wants.html { redirect_to destination_after_submit }
            wants.js   { hobo_ajax_response || render(:text => "") }
          end
        else
          respond_to do |wants|
            wants.html { re_render_form(:new) }
            wants.js   { render(:status => 500,
                                :text => ("There was a problem creating that #{this.class.name.humanize.downcase}.\n" +
                                          this.errors.full_messages.join("\n"))) }
          end
        end
    end
    

    def hobo_update(*args, &b)
      options = LazyHash.new(args.extract_options!)
      
      self.this ||= args.first || find_instance
      changes = options[:attributes] || attribute_parameters
      this.user_save_changes(current_user, changes)

      # Ensure current_user isn't out of date
      @current_user = @this if @this == current_user
      
      in_place_edit_filed = changes.keys.first if changes.size == 1 && params[:render]
      update_response(in_place_edit_field, &b)
    end
    
    
    def update_response(in_place_edit_filed=nil, &b)
      flash[:notice] = "Changes to the #{@this.class.name.humanize.downcase} were saved" if !request.xhr? && valid?
      
      response_block(&b) or 
        if valid?
          respond_to do |wants|
            wants.html do
              redirect_to destination_after_submit
            end
            wants.js do
              if in_place_edit
                # Decreasingly hacky support for the scriptaculous in-place-editor
                new_val = Hobo::Dryml.render_tag(@template, "view", :field => in_place_edit_field, :no_wrapper => true)
                hobo_ajax_response(this, :new_field_value => new_val)
              else
                hobo_ajax_response(this)
              end
               
              # Maybe no ajax requests were made
              render :nothing => true unless performed?
            end
          end
        else
          respond_to do |wants|
            wants.html { re_render_form(:edit) }
            wants.js { render(:status => 500,
                              :text => ("There was a problem with that change.\n" + 
                                        @this.errors.full_messages.join("\n"))) }
          end
        end
    end
    
    
    def hobo_destroy(*args, &b)
      options = LazyHash.new(args.extract_options!)

      self.this ||= args.first || find_instance

      this.user_destroy(current_user)
      flash[:notice] = "The #{model.name.titleize.downcase} was deleted" unless request.xhr?

      destroy_response(&b)
    end
    
    
    def destroy_response(&b)
      response_block(&b) or
        respond_to do |wants|
          wants.html { redirect_to(:action => "index") }
          wants.js   { hobo_ajax_response || render(:text => "") }
        end
    end
 
    
    def hobo_show_collection(collection, *args, &b)
      options = LazyHash.new(args.extract_options!)

      if collection.is_a?(String, Symbol)
        @owner = find_instance
        @association = @owner.send(collection)
      else
        @owner = collection.proxy_owner
        @association = collection
      end
      
      raise Hobo::Model::PermissionDeniedError unless Hobo.can_view?(current_user, @owner, @association.proxy_reflection.association_name)
      self.this = paginated_find(@owner, collection, options)
      
      response_block(&b)
    end
    
    # TODO: This action needs some more tidying up    
    def hobo_new_in_collection(collection, *args, &b)
      options = LazyHash.new(args.extract_options!)

      @association = collection.is_a?(Array) ? collection : find_instance.send(collection)

      self.this ||= args.first || @association.new
      this.user_changes(current_user)
      
      response_block(&b)
    end
    

    def hobo_completions
      opts = self.class.autocompleter(params[:for])
      if opts
        # Eval any defined filters
        instance_eval(&opts[:data_filters_block]) if opts[:data_filters_block]
        conditions = data_filter_conditions
        q = params[:query]
        items = model.find(:all) { all?(send("#{attr}_contains", q), conditions && block(conditions)) }

        render :text => "<ul>\n" + items.map {|i| "<li>#{i.send(attr)}</li>\n"}.join + "</ul>"
      else
        render :text => "No completer for #{attr}", :status => 404
      end
    end
    
    #def hobo_create_in_collection(collection, options={}, &b)
    #  hobo_create do
    #    hobo_new_in_collection(collection, :this => @this, &b)
    #  end
    #end
    
    
    # --- Response helpers --- #

    
    def permission_denied(error)
      if respond_to? :permission_denied_response
        permission_denied_response
      elsif render_tag("permission-denied-page", { }, :status => 403)
        # job done
      else
        render :text => "Permission Denied", :status => 403
      end
    end
    
    
    def not_found(error)
      if respond_to? :not_found_response
        not_found_response
      elsif render_tag("not-found-page", {}, :status => 404)
        # cool
      else
        render(:text => "The page you requested cannot be found.", :status => 404)
      end
    end
    
    
    def this
      @this ||= (instance_variable_get("@#{model.name.underscore}") || 
                 instance_variable_get("@#{model.name.underscore.pluralize}"))
    end

    
    def this=(object)
      ivar = if object.is_a?(Array)
               if object.respond_to?(:member_class)
                 object.member_class.name.underscore.pluralize
               else
                 model.name.underscore.pluralize
               end
             else
               model.name.underscore
             end
      @this = instance_variable_set("@#{ivar}", object)
    end
    
    
    def dryml_context
      this
    end

    
    def render_with_hobo_model(*args, &block)
      options = args.extract_options!
      self.this = options[:object] if options[:object]
      this.user_view(current_user) if this && this.respond_to?(:user_view)
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
    

    def model
      self.class.model
    end
    

    def data_filter_conditions
      active_filters = data_filters && (params.keys & data_filters.keys)
      filters = data_filters
      params = self.params
      proc do
        all?(*active_filters.map {|f| instance_exec(params[f], &filters[f])})
      end unless active_filters.blank?
    end
    
  end

end
