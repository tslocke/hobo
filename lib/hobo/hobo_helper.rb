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
      request.relative_url_root
    end


    def controller_for(obj)
      if obj.is_a? Class
        obj.name.underscore.pluralize
      else
        obj.class.name.underscore.pluralize
      end
    end


    def subsite
      params[:controller].match(/([^\/]+)\//)._?[1]
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
        v = if obj.is_a?(ActiveRecord::Base) or obj.is_a?(Array)
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
      HoboFields.to_name(type) || type.name.underscore.gsub("/", "__")
    end


    def type_and_field(*args)
      type, field = args.empty? ? [this_parent.class, this_field] : args
      "#{type.typed_id}_#{field}" if type.respond_to?(:typed_id)
    end


    def model_id_class(object=this, attribute=nil)
      object.respond_to?(:typed_id) ? "model::#{typed_id(object, attribute).to_s.dasherize}" : ""
    end


    def context_map(enum = this)
      # TODO: Calls to respond_to? in here can cause the full collection hiding behind a scoped collection to get loaded
      res = []
      empty = true
      scope.new_scope(:repeat_collection => enum, :even_odd => 'odd') do
        if enum.respond_to?(:each_pair)
          enum.each_pair do |key, value|
            empty = false;
            self.this_key = key;
            new_object_context(value) { res << yield }
            scope.even_odd = scope.even_odd == "even" ? "odd" : "even"
          end
        else
          index = 0
          enum.each do |e|
            empty = false;
            if enum == this
              new_field_context(index, e) { res << yield }
            else
              new_object_context(e) { res << yield }
            end
            scope.even_odd = scope.even_odd == "even" ? "odd" : "even"
            index += 1
          end
        end
        Dryml.last_if = !empty
      end
      res
    end
    
    
    def first_item?
      this == scope.repeat_collection.first
    end
    
    
    def last_item?
      this == scope.repeat_collection.last
    end


    def comma_split(x)
      case x
      when nil
        []
      when Symbol
        x.to_s
      when String
        x.strip.split(/\s*,\s*/)
      else
        x.compact.map{|e| comma_split(e)}.flatten
      end
    end


    def can_create?(object=this)
      Hobo.can_create?(current_user, object)
    end


    def can_update?(object, new)
      Hobo.can_update?(current_user, object, new)
    end


    def can_edit?(*args)
      if args.empty?
        if this.respond_to?(:updatable_by?) && !this_field_reflection
          can_edit?(this, nil)
        elsif this_parent && this_field
          can_edit?(this_parent, this_field)
        else
          can_edit?(this, nil)
        end
      else
        object, field = args.length == 2 ? args : [this, args.first]

        if !field && (origin = object.try.origin)
          Hobo.can_edit?(current_user, origin, object.origin_attribute)
        else
          Hobo.can_edit?(current_user, object, field)
        end
      end
    end


    def can_delete?(object=nil)
      Hobo.can_delete?(current_user, object || this)
    end


    def can_view?(object=nil, field=nil)
      if object.nil? && field.nil?
        if this_parent && this_field
          object, field = this_parent, this_field
        else
          object = this
        end
      end

      @can_view_cache ||= {}
      @can_view_cache[ [object, field] ] ||=
        if !field && (origin = object.try.origin)
          Hobo.can_view?(current_user, origin, object.origin_attribute)
        else
          Hobo.can_view?(current_user, object, field)
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


    def param_name_for(path)
      field_path = field_path.to_s.split(".") if field_path.is_a?(String, Symbol)
      attrs = path.rest.map{|part| "[#{part.to_s.sub /\?$/, ''}]"}.join
      "#{path.first}#{attrs}"
    end


    def param_name_for_this(foreign_key=false)
      return "" unless form_this
      name = if foreign_key && (refl = this_field_reflection) && refl.macro == :belongs_to
               param_name_for(path_for_form_field[0..-2] + [refl.primary_key_name])
             else
               param_name_for(path_for_form_field)
             end
      register_form_field(name)
      name
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
      model_or_assoc.user_new(current_user)
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
      query = request.request_uri.match(/(?:\?([^?]+))/)._?[1]
      if query
        params = query.split('&')
        pairs = params.map do |param|
          pair = param.split('=', 2)
          pair.length == 1 ? pair + [''] : pair
        end
        HashWithIndifferentAccess[*pairs.flatten]
      else
        HashWithIndifferentAccess.new
      end
    end

    def linkable?(*args)
      options = args.extract_options!
      target = args.empty? || args.first.is_a?(Symbol) ? this : args.shift
      action = args.first

      if (origin = target.try.origin)
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
    

    # Convenience helper for the default app

    # FIXME: this should interrogate the routes to find index methods, not the models
    def front_models
      Hobo::Model.all_models.select {|m| linkable?(m) }
    end
    
    
    def this_field_name
      this_parent.class.view_hints.field_name(this_field)
    end

    def this_field_help
      this_parent.class.view_hints.field_help[this_field.to_sym]
    end


    # debugging support

    def abort_with(*args)
      raise args.map{|arg| PP.pp(arg, "")}.join("-------\n")
    end

    def log_debug(*args)
      logger.debug("\n### DRYML Debug ###")
      logger.debug(args.map {|a| PP.pp(a, "")}.join("-------\n"))
      logger.debug("DRYML THIS = #{this.typed_id rescue this.inspect}")
      logger.debug("###################\n")
      args.first unless args.empty?
    end

  end

end
