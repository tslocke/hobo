module Hobo
  
  module HoboHelper
  
    def self.add_to_controller(controller)
      controller.send(:include, self)
      controller.hide_action(self.instance_methods)
    end
     
    protected
     
    def current_user
      # simple one-hit-per-request cache
      @current_user or
        @current_user = if Hobo.user_model and session and id = session[:user]
                               Hobo.user_model.find(id)
                             else 
                               Guest.new
                             end 
    end
     
     
    def logged_in?
      not current_user.guest?
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
     
     
    def object_url(obj, action=nil, *param_hashes)
      action &&= action.to_s
      
      controller_name = controller_for(obj)
      
      parts = if obj.is_a? Class
                [base_url, controller_name]
                
              elsif obj.is_a? Hobo::CompositeModel
                [base_url, controller_name, obj.id]
                
              elsif obj.is_a? ActiveRecord::Base
                if obj.new_record?
                  [base_url, controller_name]
                else
                  raise HoboError.new("invalid object url: new for existing object") if action == "new"
     
                  klass = obj.class
                  id = if klass.id_name?
                         obj.id_name(true)
                       else
                         obj.id
                       end
                  
                  [base_url, controller_name, id]
                end
                
              elsif obj.is_a? Array    # warning - this breaks if we use `case/when Array`
                owner = obj.proxy_owner
                new_model = obj.proxy_reflection.klass
                [object_url(owner), obj.proxy_reflection.name]
                
              else
                raise HoboError.new("cannot create url for #{obj.inspect} (#{obj.class})")
              end
      basic = parts.join("/")
      
      controller = (controller_name.camelize + "Controller").constantize rescue nil
      url = if action && controller && action.to_sym.in?(controller.web_methods)
              basic + "/#{action}"
            else
              case action
              when "new"
                basic + "/new"
              when "destroy"
                basic + "?_method=DELETE"
              when "update"
                basic + "?_method=PUT"
              when nil
                basic
              else
                basic + "/" + action
              end
            end
      params = make_params(*param_hashes)
      params.blank? ? url : url + "?" + params
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
              "@" + dom_id(obj)
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
     
     
    def dom_id(x, attr=nil)
      Hobo.dom_id(x, attr)
    end
     
     
    def map_this
      res = []
      this.each_index {|i| new_field_context(i) { res << yield } }
      Dryml.last_if = !this.empty?
      res
    end
    alias_method :collect_this, :map_this
     
     
    def comma_split(x)
      case x
      when nil
        []
      when Symbol
        x.to_s
      when String
        x.split(/\s*,\s*/)
      else
        x.map{|e| comma_split(e)}.flatten
      end
    end
     
     
    def can_create?(object=nil)
      Hobo.can_create?(current_user, object || this)
    end
     
     
    def can_update?(object, new)
      Hobo.can_update?(current_user, object, new)
    end
     
     
    def can_edit?(*args)
      if args.empty?
        this_parent && this_field && can_edit?(this_parent, this_field)
      else
        object, field = args.length == 2 ? args : [this, args.first]
        
        if !field and object.respond_to?(:proxy_reflection)
          Hobo.can_edit?(current_user, object.proxy_owner, object.proxy_reflection.name)
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
      
      if !field and object.respond_to?(:proxy_reflection)
        Hobo.can_view?(current_user, object.proxy_owner, object.proxy_reflection.name)
      else
        Hobo.can_view?(current_user, object, field)
      end
    end
     
     
    def select_viewable(collection)
      collection.select {|x| can_view?(x)}
    end
     
     
    def theme_asset(path)
      "#{base_url}/hobothemes/#{Hobo.current_theme}/#{path}"
    end
     
    def js_str(s)
      if s.is_a? Hobo::RawJs
        s.to_s
      else
        "'" + s.gsub("'"){"\\'"} + "'"
      end
    end
     
     
    def make_params_js(*args)
      ("'" + make_params(*args) + "'").sub(/ \+ ''$/,'')
    end
     
     
    def render_params(*args)
      parts = args.map{|x| x.split(/, */) if x}.compact.flatten
      { :part_page => view_name,
        :render => parts.map do |part_id|
          { :object => Hobo::RawJs.new("hoboParts.#{part_id}"),
            :part => part_id }
        end
      }
    end
     
     
    def nl_to_br(s)
      s.to_s.gsub("\n", "<br/>") if s
    end
     
     
    def param_name_for(object, field_path)
      field_path = field_path.to_s.split(".") if field_path.is_a?(String, Symbol)
      attrs = field_path.map{|part| "[#{part.to_s.sub /\?$/, ''}]"}.join
      "#{object.class.name.underscore}#{attrs}"
    end
     
     
    def param_name_for_this(foreign_key=false)
      return "" unless form_this
      name = if foreign_key and this_type.respond_to?(:macro) and this_type.macro == :belongs_to
               param_name_for(form_this, form_field_path[0..-2] + [this_type.primary_key_name])
             else
               param_name_for(form_this, form_field_path)
             end
      register_form_field(name)
      name
    end
     
     
    def selector_type
      if this.is_a? ActiveRecord::Base
        this.class
      elsif this.respond_to? :member_class
        this.member_class
      elsif this == @this
        @model
      end
    end
     
     
    def transpose_with_field(field)
      matrix = this.map {|obj| obj.send(field) }
      max_length = matrix.every(:length).max
      matrix = matrix.map do |a|
        a + [nil] * (max_length - a.length)
      end
      matrix.transpose
    end
     
     
    def create(model)
      n = model.new
      n.set_creator(current_user)
      n
    end
     
     
    # debugging support
     
    def abort_with(*args)
      raise args.map{|arg| PP.pp(arg, "")}.join("-------\n")
    end
     
    def log_debug(*args)
      logger.debug("\n### DRYML Debug ###")
      logger.debug(args.map {|a| PP.pp(a, "")}.join("-------\n"))
      logger.debug("DRYML THIS = #{Hobo.dom_id(this)}")
      logger.debug("###################\n")
      args.first unless args.empty?
    end
    
  end

end
