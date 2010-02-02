module Hobo

  module HoboHelper

    def self.add_to_controller(controller)
      controller.send(:include, self)
      controller.hide_action(self.instance_methods)
    end

    protected


    def uid
      @hobo_uid ||= 0
      @hobo_uid += 1
    end


    def current_user
      # simple one-hit-per-request cache
      @current_user ||= begin
                          id = session._?[:user]
                          (id && Hobo::Model.find_by_typed_id(id) rescue nil) || ::Guest.new
                        end
    end


    def logged_in?
      !current_user.guest?
    end


    def base_url
      ActionController::Base.relative_url_root || ""
    end


    def controller_for(obj)
      if obj.is_a? Class
        obj.name.underscore.pluralize
      else
        obj.class.name.underscore.pluralize
      end
    end


    def subsite
      params[:controller]._?.match(/([^\/]+)\//)._?[1]
    end


    IMPLICIT_ACTIONS = [:index, :show, :create, :update, :destroy]

    def object_url(obj, *args)
      params = args.extract_options!
      action = args.first._?.to_sym
      options, params = params.partition_hash([:subsite, :method, :format])
      options[:subsite] ||= self.subsite
      subsite, method = options.get :subsite, :method

      if obj.respond_to?(:member_class) && obj.respond_to?(:origin)
        # Asking for URL of a collection, e.g. category/1/adverts or category/1/adverts/new
        
        refl = obj.origin.class.reverse_reflection(obj.origin_attribute)
        owner_name = refl.name.to_s
        owner_name = owner_name.singularize if refl.macro == :has_many
        if action == :new
          action_path = "#{obj.origin_attribute}/new"
          action = :"new_for_#{owner_name}"
        elsif action.nil?
          action_path = obj.origin_attribute
          if method.to_s == 'post'
            action = :"create_for_#{owner_name}"
          else
            action = :"index_for_#{owner_name}"
          end
        end
        klass = obj.member_class
        obj = obj.origin
      else
        action ||= case options[:method].to_s
                   when 'put';    :update
                   when 'post';   :create
                   when 'delete'; :destroy
                   else; obj.is_a?(Class) ? :index : :show
                   end

        if options[:method].to_s == 'post' && obj.try.new_record?
          # Asking for url to post new record to
          obj = obj.class
        end
        
        klass = if obj.is_a?(Class)
                  obj
                elsif obj.respond_to?(:member_class)
                  obj.member_class # We get here if we're passed a scoped class
                else
                  obj.class
                end
      end

      if Hobo::ModelRouter.linkable?(klass, action, options)

        url = base_url_for(obj, subsite, action)
        url += "/#{action_path || action}" unless action.in?(IMPLICIT_ACTIONS)

        params = make_params(params)
        params.blank? ? url : "#{url}?#{params}"
      end
    end


    def base_url_for(object, subsite, action)
      path = object.to_url_path or HoboError.new("cannot create url for #{object.inspect} (#{object.class})")
      "#{base_url}#{'/' + subsite unless subsite.blank?}/#{path}"
    end


    def _as_params(name, obj)
      if obj.is_a? Array
        obj.map {|x| _as_params("#{name}[]", x)}.join("&")
      elsif obj.is_a? Hash
        obj.map {|k,v| _as_params("#{name}[#{k}]", v)}.join("&")
      elsif obj.is_a? Hobo::RawJs
        "#{name}=' + #{obj} + '"
      else
        v = if obj.is_one_of?(ActiveRecord::Base, Array)
              "@" + typed_id(obj)
            else
              obj.to_s.gsub("'"){"\\'"}
            end
        "#{name}=#{v}"
      end
    end


    def make_params(*hashes)
      hash = {}
      hashes.each {|h| hash.update(h) if h}
      hash.map {|k,v| _as_params(k, v)}.join("&")
    end


    def type_id(type=nil)
      type ||= (this.is_a?(Class) && this) || this_type || this.class
      HoboFields.to_name(type) || type.name.to_s.underscore.gsub("/", "__")
    end


    def type_and_field(*args)
      type, field = args.empty? ? [this_parent.class, this_field] : args
      "#{type.typed_id}_#{field}" if type.respond_to?(:typed_id)
    end


    def model_id_class(object=this, attribute=nil)
      object.respond_to?(:typed_id) ? "model::#{typed_id(object, attribute).to_s.dasherize}" : ""
    end

    def can_create?(object=this)
      if object.is_a?(Class) and object < ActiveRecord::Base
        object = object.new
      elsif (refl = object.try.proxy_reflection) && refl.macro == :has_many
        if Hobo.simple_has_many_association?(object)
          object = object.new
          object.set_creator(current_user)
        else
          return false
        end
      end
      object.creatable_by?(current_user)
    end


    def can_update?(object=this)
      object.updatable_by?(current_user)
    end


    def can_edit?(*args)
      object, field = if args.empty?
                        if this.respond_to?(:editable_by?) && !this_field_reflection
                          [this, nil]
                        elsif this_parent && this_field
                          [this_parent, this_field]
                        else 
                          [this, nil]
                        end
                      elsif args.length == 2
                        args
                      else
                        [this, args.first]
                      end

      if !field && (origin = object.try.origin)
        object, field = origin, object.origin_attribute
      end

      object.editable_by?(current_user, field)
    end
    

    def can_delete?(object=this)
      object.destroyable_by?(current_user)
    end


    
    def can_call?(*args)
      method = args.last
      object = args.length == 2 ? args.first : this

      object.method_callable_by?(current_user, method)
    end

    
    # can_view? has special behaviour if it's passed a class or an
    # association-proxy -- it instantiates the class, or creates a new
    # instance "in" the association, and tests the permission of this
    # object. This means the permission methods in models can't rely
    # on the instance being properly initialised.  But it's important
    # that it works like this because, in the case of an association
    # proxy, we don't want to loose the information that the object
    # belongs_to the proxy owner.
    def can_view?(*args)
      # TODO: Man does this need a big cleanup!
      
      if args.empty?
        if this_parent && this_field
          object = this_parent
          field = this_field
        else
          object = this
        end
      elsif args.first.is_one_of?(String, Symbol)
        object = this
        field  = args.first
      else
        object, field = args
      end
      
      if field
        # Field can be a dot separated path
        if field.is_a?(String) && (path = field.split(".")).length > 1
          _, _, object = Hobo.get_field_path(object, path[0..-2])
          field = path.last
        end
      elsif (origin = object.try.origin)
        object, field = origin, object.origin_attribute
      end
      
      @can_view_cache ||= {}
      @can_view_cache[ [object, field] ] ||=
        if !object.respond_to?(:viewable_by?)
          true
        elsif object.viewable_by?(current_user, field)
          # If possible, we also check if the current *value* of the field is viewable
          if field.is_one_of?(Symbol, String) && (v = object.send(field)) && v.respond_to?(:viewable_by?)
            v.viewable_by?(current_user, nil)
          else
            true
          end
        else
          false
        end
    end
    

    def select_viewable(collection=this)
      collection.select {|x| can_view?(x)}
    end


    def theme_asset(path)
      theme_path = Hobo.current_theme ? "hobothemes/#{Hobo.current_theme}/" : ""
      "#{base_url}/#{theme_path}#{path}"
    end

    def js_str(s)
      if s.is_a? Hobo::RawJs
        s.to_s
      else
        "'" + s.to_s.gsub("'"){"\\'"} + "'"
      end
    end


    def make_params_js(*args)
      ("'" + make_params(*args) + "'").sub(/ \+ ''$/,'')
    end


    def nl_to_br(s)
      s.to_s.gsub("\n", "<br/>") if s
    end

    def transpose_with_field(field, collection=nil)
      collection ||= this
      matrix = collection.map {|obj| obj.send(field) }
      max_length = matrix.*.length.max
      matrix = matrix.map do |a|
        a + [nil] * (max_length - a.length)
      end
      matrix.transpose
    end


    def new_for_current_user(model_or_assoc=nil)
      model_or_assoc ||= this
      if model_or_assoc.respond_to?(:new_candidate)
        model_or_assoc.user_new_candidate(current_user)
      else
        model_or_assoc.user_new(current_user)
      end
    end


    def defined_route?(r)
      @view.respond_to?("#{r}_url")
    end


    # Login url for a given user record or user class
    def forgot_password_url(user_class=Hobo::User.default_user_model)
      send("#{user_class.name.underscore}_forgot_password_url") rescue nil
    end


    # Login url for a given user record or user class
    def login_url(user_class=Hobo::User.default_user_model)
      send("#{user_class.name.underscore}_login_url") rescue nil
    end


    # Sign-up url for a given user record or user class
    def signup_url(user_class=Hobo::User.default_user_model)
      send("#{user_class.name.underscore}_signup_url") rescue nil
    end


    # Login url for a given user record or user class
    def logout_url(user_or_class=nil)
      c = if user_or_class.nil?
            current_user.class
          elsif user_or_class.is_a?(Class)
            user_or_class
          else
            user_or_class.class
          end
      send("#{c.name.underscore}_logout_url") rescue nil
    end


    def current_page_url
      request.request_uri.match(/^([^?]*)/)._?[1]
    end

    def query_params
      query = request.request_uri =~ /\?([^?]+)/ && $1
      result = HashWithIndifferentAccess.new 
      if query
        query.gsub!('+', ' ')
        query.split('&').each do |param|
          name, val = param.split('=', 2)
          result[URI.unescape(name)] = val ? URI.unescape(val) : ''
        end
      end
      result
    end


    def linkable?(*args)
      options = args.extract_options!
      target = args.empty? || args.first.is_a?(Symbol) ? this : args.shift
      action = args.first

      if target.respond_to?(:member_class) && (origin = target.try.origin)
        klass = origin.class
        action = if action == :new
                   "new_#{target.origin_attribute.to_s.singularize}"
                 elsif action.nil?
                   target.origin_attribute
                 end
      elsif target.is_a?(Class)
        klass = target
        action ||= :index
      else
        klass = target.class
        action ||= :show
      end

      Hobo::ModelRouter.linkable?(klass, action, options.reverse_merge(:subsite => subsite))
    end
    
    
    def css_data(name, *args)
      "#{name.to_s.dasherize}::#{args * '::'}"
    end
        

    # --- ViewHint Helpers --- #
    
    def this_field_name
      this_parent.class.try.view_hints.try.field_name(this_field) || this_field
    end

    def this_field_help
      key = "#{this_parent.class.try.name.tableize}.hints.#{this_field.to_s}"
      default = this_parent.class.try.view_hints.try.field_help[this_field.to_sym] || ""
      Hobo::Translations.ht(key, :default=>default)
    end


    # --- Debugging Helpers ---- #

    def abort_with(*args)
      raise args.*.pretty_inspect.join("-------\n")
    end

    def log_debug(*args)
      return if not logger
      logger.debug("\n### DRYML Debug ###")
      logger.debug(args.*.pretty_inspect.join("-------\n"))
      logger.debug("DRYML THIS = #{this.typed_id rescue this.inspect}")
      logger.debug("###################\n")
      args.first unless args.empty?
    end    

  end

end
