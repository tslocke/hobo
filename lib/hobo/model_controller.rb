module Hobo

  module ModelController

    include Hobo::Controller

    class PermissionDeniedError < RuntimeError; end

    VIEWLIB_DIR = "hobolib"
    
    GENERIC_PAGE_TAGS = [:index, :show, :new, :edit, :show_collection, :new_in_collection]

    class << self

      def included(base)
        base.extend(ClassMethods)
        base.helper_method(:find_partial, :model, :current_user)

        Hobo::ControllerHelpers.public_instance_methods.each {|m| base.hide_action(m)}

        for collection in base.collections
          add_collection_actions(base, collection)
        end

        base.before_filter :set_no_cache_headers
      end

      def find_partial(klass, as)
        find_model_template(klass, as, true)
      end


      def template_path(dir, name, is_partial)
        fileRx = is_partial ? /^_#{name}\.[^.]+/ : /^#{name}\.[^.]+/
        unless Dir.entries("#{RAILS_ROOT}/app/views/#{dir}").grep(fileRx).empty?
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
        
        show_collection_method = "show_#{name}"
        unless show_collection_method.in?(defined_methods)
          controller_class.class_eval <<-END, __FILE__, __LINE__+1
            def #{show_collection_method}
              @owner = find_instance
              if Hobo.can_view?(current_user, @owner, :#{name})
                @association = @owner.#{name}
                @pages = ::ActionController::Pagination::Paginator.new(self, @association.size, 20, params[:page])
                options = { :limit  =>  @pages.items_per_page, :offset =>  @pages.current.offset }
                @this = @association.find(:all, options)
                @this = @this.uniq if @association.proxy_reflection.options[:uniq]
                hobo_render(:#{show_collection_method}) or hobo_render(:show_collection, @association.member_class)
              else
                permission_denied
              end
            end
          END
        end
          
        if Hobo.simple_has_many_association?(controller_class.model.reflections[name.to_sym])
          new_method = "new_#{name.to_s.singularize}"
          if new_method.not_in?(defined_methods)
            controller_class.class_eval <<-END, __FILE__, __LINE__+1
              def #{new_method}
                @owner = find_instance
                if Hobo.can_view?(current_user, @owner, :#{name})
                  @this = @owner.#{name}.new_without_appending
                  @this.created_by(current_user)
                  hobo_render(:#{new_method}) or hobo_render(:new_in_collection, @this.class)
                else
                  permission_denied
                end
              end
            END
          end
        end
      end

    end

    module ClassMethods

      attr_writer :model
      
      def web_methods
        @web_methods ||= []
      end
      
      def show_actions
        @show_actions ||= []
      end
      
      def collections
        # By default, all has_many associations are published
        @collections ||= model.reflections.values.map {|r| r.name if r.macro == :has_many}.compact
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
          class_eval "def #{name}; show; end"
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

    def index
      @model = model
      count = count_with_data_filter
      @pages = ::ActionController::Pagination::Paginator.new(self, count, 20, params[:page])
      options = { :limit  =>  @pages.items_per_page, :offset =>  @pages.current.offset, :order => :default }
      @this = find_with_data_filter(options)
      hobo_render
    end


    def show
      @this = find_instance
      if @this
        if Hobo.can_view?(current_user, @this)
          hobo_render
        else
          permission_denied
        end
      else
        render :text => "Can't find #{model.name.titleize}: #{params[:id]}", :status => 404
      end
    end


    def new
      @this = model.new
      @this.created_by(current_user)
      if Hobo.can_create?(current_user, @this)
        hobo_render
      else
        permission_denied
      end
    end


    def create
      attributes = params[model.name.underscore]
      type_attr = params['type']
      create_model = if 'type'.in?(model.column_names) and 
                         type_attr and type_attr.in?(model.send(:subclasses).omap{name})
                       type_attr.constantize
                     else
                       model
                     end
      @this = create_model.new
      @check_create_permission = [@this]
      initialize_from_params(@this, attributes)
      for obj in @check_create_permission
        permission_denied and return unless Hobo.can_create?(current_user, obj)
      end
      @check_create_permission = nil
      
      if @this.save
        respond_to do |wants|
          wants.html do
            create_response
            redirect_to object_url(@this) unless performed?
          end

          wants.js   { hobo_ajax_response(@this) or render :text => "" }
        end
      else
        # Validation errors
        respond_to do |wants|
          wants.html do
            invalid_create_response
            hobo_render :new unless performed?
          end

          wants.js do
            render(:status => 500,
                   :text => "There was a problem creating that #{create_model.name}.\n" +
                            @this.errors.full_messages.join("\n"))
          end
        end
      end
    end


    def edit
      @this = find_instance
      hobo_render
    end


    def update
      @this = find_instance
      original = @this.duplicate
      changes = params[model.name.underscore]
      
      render :nothing => true and return unless changes
      
      update_with_params(@this, changes)
      permission_denied and return unless Hobo.can_update?(current_user, original, @this)
      if @this.save
        respond_to do |wants|
          wants.html do
            update_response
            redirect_to object_url(@this) unless performed?
          end

          wants.js do
            if changes.size == 1
              # Decreasingly hacky support for the scriptaculous in-place-editor
              new_val = Hobo::Dryml.render_tag(@template, "show",
                                               :obj => @this, :attr => changes.keys.first, :no_span => true)
              hobo_ajax_response(@this, :new_field_value => new_val)
            else
              hobo_ajax_response(@this)
            end
            
            # Maybe no ajax requests were made
            render :nothing => true unless performed?
          end
        end
      else
        # Validation errors
        respond_to do |wants|
          wants.html do
            invalid_update_response
            render :action => :edit unless performed?
          end

          wants.js do
            # Temporary hack
            render(:status => 500,
                   :text => ("There was a problem with that change.\n" +
                             @this.errors.full_messages.join("\n")))
          end
        end
      end
    end


    def destroy
      @this = find_instance
      permission_denied and return unless Hobo.can_delete?(current_user, @this)

      @this.destroy

      respond_to do |wants|
        wants.html do
          destroy_response
          redirect_to :action => "index" unless performed?
        end
        wants.js { hobo_ajax_response(@this) or render :text => "" }
      end
    end


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
    
    # --- hooks --- #
    
    def create_response; end
    
    def invalid_create_response; end
    
    def update_response; end
    
    def invalid_update_response; end
    
    def destroy_response; end 
    
    # --- end hooks --- #
    
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


    def permission_denied
      render :text => "Permission Denied", :status => 403
    end


    def find_instance(id=nil)
      id ||= params[:id]
      res = if respond_to?(:find_for_show)
              find_for_show(id)
            else
              self.class.find_instance(id || params[:id])
            end
      instance_variable_set("@#{model.name.underscore}", res)
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
          render_tag("#{page_kind}_page", :obj => @this)
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
      filter_param = params.keys.ofind {starts_with? "where_"}
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
      obj.created_by(current_user)
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
      if field_type <= Date
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
