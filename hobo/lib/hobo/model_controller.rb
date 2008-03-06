module Hobo

  module ModelController

    include Hobo::Controller

    VIEWLIB_DIR = "taglibs"
    
    PAGINATE_FORMATS = [ Mime::HTML, Mime::ALL ]
    
    READ_ONLY_ACTIONS  = [:index, :show]
    WRITE_ONLY_ACTIONS = [:create, :update, :destroy]
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
      
      
      def autocomplete_for(field, options={})
        options = options.reverse_merge(:limit => 15)
        index_action "complete_#{field}" do
          hobo_completions(model.limit(options[:limit]).send("#{field}_contains", params[:query]))
        end
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
    
    
    def filter_by(*args)
      filters = args.extract_options!
      finder = args.first || self.model
      
      filters.each_pair do |scope, arg|
        dont_filter = arg.is_a?(Array) ? arg.compact.empty? : arg.nil?
        finder = finder.send(scope, arg) unless dont_filter
      end
      finder
    end
    
    
    def sort_fields(*args)
      finder = args.first.is_a?(Class) ? args.shift : model
      
      _, desc, field = *params[:sort]._?.match(/^(-)?([a-z_]+(?:\.[a-z_]+)?)$/)

      if field
        fields = args.*.to_s
        if field.in?(fields)
          @sort_field = field
          @sort_direction = desc ? "desc" : "asc"
        
          table, column = if field =~ /^(.*)\.(.*)$/
                            [$1.camelize.constantize.table_name, $2]
                          else
                            [finder.table_name, field]
                          end
          finder = finder.order("#{table}.#{column}", @sort_direction)
        end
      end
      finder
    end
    
    
    # --- Action implementation helpers --- #
    

    def find_instance(*args)
      options = args.extract_options!
      id = args.first || params[:id]
      model.user_find(current_user, id, options)
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
        
        # Then try the record's show page
        object_url(@this) || 
        
        # Then the show page of the 'owning' object if there is one
        (@this.class.default_dependent_on && object_url(@this.class.default_dependent_on)) ||
        
        # Last try - the index page for this model
        object_url(@this.class) ||
        
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
    
    def paginate(finder, options)
      do_pagination = options.fetch(:paginate, request.format.in?(PAGINATE_FORMATS))
      if do_pagination && !finder.respond_to?(:paginate)
        do_pagination = false
        logger.warn "Hobo::ModelController: Pagination is not available. To enable, please install will_paginate or a duck-type compatible paginator"
      end

      if do_pagination
        finder.paginate(options)
      else
        finder.find(:all, options)
      end
    end
    
    # --- Action implementations --- #

    def hobo_index(*args, &b)
      options = args.extract_options!
      options = options.reverse_merge(:page => params[:page] || 1)
      finder = args.first || model
      self.this = finder.paginate(options)
      response_block(&b)
    end
    

    def hobo_show(*args, &b)
      options = args.extract_options!
      self.this ||= find_instance(options)
      response_block(&b)
    end
    
    
    def hobo_new(new_record=nil, &b)
      self.this = new_record || model.new
      this.user_changes(current_user) # set_creator and permission check
      response_block(&b)
    end
    
    
    def hobo_create(*args, &b)
      options = args.extract_options!
      self.this = args.first || new_for_create
      this.user_save_changes(current_user, options[:attributes] || attribute_parameters)
      create_response(&b)
    end
    
    
    def attribute_parameters
      params[this.class.name.underscore]
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
                                :text => ("Couldn't create the #{this.class.name.titleize.downcase}.\n" +
                                          this.errors.full_messages.join("\n"))) }
          end
        end
    end
    

    def hobo_update(*args, &b)
      options = args.extract_options!
      
      self.this ||= args.first || find_instance
      changes = options[:attributes] || attribute_parameters
      this.user_save_changes(current_user, changes)

      # Ensure current_user isn't out of date
      @current_user = @this if @this == current_user
      
      in_place_edit_field = changes.keys.first if changes.size == 1 && params[:render]
      update_response(in_place_edit_field, &b)
    end
    
    
    def update_response(in_place_edit_field=nil, &b)
      flash[:notice] = "Changes to the #{@this.class.name.humanize.downcase} were saved" if !request.xhr? && valid?
      
      response_block(&b) or 
        if valid?
          respond_to do |wants|
            wants.html do
              redirect_to destination_after_submit
            end
            wants.js do
              if in_place_edit_field
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
      options = args.extract_options!
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
 
    
    def hobo_show_collection(association, *args, &b)
      options = args.extract_options!
      options = options.reverse_merge(:page => params[:page] || 1)
      association = find_instance.send(association) if association.is_a?(String, Symbol)
      if association.respond_to?(:origin)
        association.origin_object.user_view(current_user, association.origin_attribute) # permission check
      end
      self.this = association.paginate(options)
      dryml_fallback_tag("show_collection_page")
      response_block(&b)
    end
    
    
    # TODO: This action needs some more tidying up    
    def hobo_new_in_collection(association, *args, &b)
      options = args.extract_options!
      association = find_instance.send(association) if association.is_a?(String, Symbol)
      self.this = args.first || association.new
      this.user_changes(current_user) # set_creator and permission check
      response_block(&b)
    end
    

    def hobo_completions(finder)
      items = finder.find(:all)
      render :text => "<ul>\n" + items.map {|i| "<li>#{i.send(attr)}</li>\n"}.join + "</ul>"
    end
    
    
    
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
               (object.try.member_class || model).name.underscore.pluralize
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
    
    public

    def model
      self.class.model
    end
    
  end

end
