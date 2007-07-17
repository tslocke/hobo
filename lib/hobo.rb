class HoboError < RuntimeError; end

module Hobo

  class RawJs < String; end

  @models = []

  class << self

    attr_accessor :current_theme
    attr_writer :developer_features

    def developer_features?
      @developer_features
    end


    def raw_js(s)
      RawJs.new(s)
    end


    def user_model=(model)
      @user_model = model && model.name
    end

    
    def user_model
      @user_model && @user_model.constantize
    end

    
    def models=(models)
      @models = models.every(:name)
    end

    
    def models
      unless @models_loaded
        Dir.entries("#{RAILS_ROOT}/app/models/").map do |f|
          f =~ /^[a-zA-Z_][a-zA-Z0-9_]*\.rb$/ and f.sub(/.rb$/, '').camelize.constantize
        end
        @models_loaded = true
      end
      @models.omap{constantize}
    end

    
    def register_model(model)
      @models << model.name unless @models.include? model.name
    end


    def object_from_dom_id(dom_id)
      return nil if dom_id == 'nil'

      _, name, id, attr = *dom_id.match(/^([a-z_]+)_([0-9]+(?:_[0-9]+)*)(_[a-z_]+)?$/)
      raise ArgumentError.new("invalid model-reference in dom id") unless name
      if name
        model_class = name.camelize.constantize rescue (raise ArgumentError.new("no such class in dom-id"))
        return nil unless model_class
        attr = attr[1..-1] if attr
        obj = if false and attr and model_class.reflections[attr.to_sym].klass.superclass == ActiveRecord::Base
                # DISABLED - Eager loading is broken - doesn't support ordering
                # http://dev.rubyonrails.org/ticket/3438
                # Don't do this for STI subclasses - it breaks!
                model_class.find(id, :include => attr)
              else
                model_class.find(id)
              end
        attr ? obj.send(attr) : obj
      end
    end

    def dom_id(obj, attr=nil)
      if obj.nil?
        raise HoboError, "Tried to get dom id of nil.#{attr}" if attr
        return 'nil'
      end

      if obj.is_a?(Array) and obj.respond_to?(:proxy_owner)
        attr = obj.proxy_reflection.name
        obj = obj.proxy_owner
      elsif !obj.respond_to?(:typed_id)
        if attr
          return dom_id(get_field(obj, attr))
        else
          raise ArgumentError, "Can't create dom id for #{obj.inspect}"
        end
      end
      attr ? "#{obj.typed_id}_#{attr}" : obj.typed_id
    end

    def find_by_search(query)
      sql = Hobo.models.map do |model|
        if model.superclass == ActiveRecord::Base # filter out STI subclasses
          cols = model.search_columns
          if cols.blank?
            nil
          else
            where = cols.map {|c| "(#{c} like ?)"}.join(' or ')
            type = model.column_names.include?("type") ? "type" : "'#{model.name}'"
            ActiveRecord::Base.send(:sanitize_sql,
                                    ["select #{type} as type, id " +
                                     "from #{model.table_name} " +
                                     "where #{where}"] +
                                    ["%#{query}%"] * cols.length)
          end
        end
      end.compact.join(" union ")

      rows = ActiveRecord::Base.connection.select_all(sql)
      records = Hash.new {|h,k| h[k] = []}
      for row in rows
        records[row['type']] << row['id']
      end
      results = []
      for type, ids in records
        results.concat(type.constantize.find(:all, :conditions => "id in (#{ids * ','})"))
      end
      
      results
    end

    def add_routes(map)
      ActiveRecord::Base.connection.reconnect! unless ActiveRecord::Base.connection.active?
      require "#{RAILS_ROOT}/app/controllers/application" unless Object.const_defined? :ApplicationController
      require "#{RAILS_ROOT}/app/assemble.rb" if File.exists? "#{RAILS_ROOT}/app/assemble.rb"
      
      for model in Hobo.models
        controller_name = "#{model.name.pluralize}Controller"
        controller = controller_name.constantize if (Object.const_defined? controller_name) || File.exists?("#{RAILS_ROOT}/app/controllers/#{controller_name.underscore}.rb")
          
        if controller
          web_name = model.name.underscore.pluralize.downcase

          # Simple support for composite models, we might later need a CompositeModelController
          if model < Hobo::CompositeModel
            map.connect "#{web_name}/:id", :controller => web_name, :action => 'show'

          elsif controller < Hobo::ModelController
            
            map.resources web_name, :collection => { :completions => :get }
            
            for collection in controller.collections
              new_method = Hobo.simple_has_many_association?(model.reflections[collection])
              Hobo.add_collection_routes(map, web_name, collection, new_method)
            end
            
            for method in controller.web_methods
              map.named_route("#{web_name.singularize}_#{method}",
                              "#{web_name}/:id/#{method}",
                              :controller => web_name,
                              :action => method.to_s,
                              :conditions => { :method => :post })
            end
            
            for view in controller.show_actions
              map.named_route("#{web_name.singularize}_#{view}",
                              "#{web_name}/:id/#{view}",
                              :controller => web_name,
                              :action => view.to_s,
                              :conditions => { :method => :get })
            end
          end
        end
      end
    end
    
    
    def add_collection_routes(map, controller_name, collection_name, new_method)
      singular_name = collection_name.to_s.singularize
      map.with_options :controller => controller_name, :conditions => { :method => :get } do |m|
        m.named_route("#{controller_name.singularize}_#{collection_name}",
                      "#{controller_name}/:id/#{collection_name}",
                      :action => "show_#{collection_name}")

        m.named_route("new_#{controller_name.singularize}_#{singular_name}",
                      "#{controller_name}/:id/#{collection_name}/new",
                      :action => "new_#{singular_name}") if new_method
      end
    end


    def all_controllers
      Hobo.models.map {|m| m.name.underscore.pluralize}
    end


    def simple_has_many_association?(array_or_reflection)
      refl = array_or_reflection.is_a?(Array) ? array_or_reflection.proxy_reflection : array_or_reflection
      return false unless refl.is_a?(ActiveRecord::Reflection::AssociationReflection)
      refl.macro == :has_many and
        (not refl.through_reflection) and
        (not refl.options[:conditions])
    end
    
    
    def get_field(object, field)
      if field.to_s =~ /\d+/
        object[field.to_i]
      else
        object.send(field)
      end
    end
    
    
    # --- Permissions --- #


    def can_create?(person, object)
      if object.is_a?(Class) and object < ActiveRecord::Base
        object = object.new
        object.set_creator(person)
      elsif Hobo.simple_has_many_association?(object)
        object = object.new_without_appending
        object.set_creator(person)
      end
      check_permission(:create, person, object)
    end


    def can_update?(person, object, new)
      check_permission(:update, person, object, new)
    end


    def can_edit?(person, object, field)
      setter = "#{field.to_s.sub /\?$/, ''}=" 
      return false unless can_view?(person, object, field) and object.respond_to?(setter)
      
      refl = object.class.reflections[field.to_sym] if object.is_a?(ActiveRecord::Base)
      
      # has_many and polymorphic associations are not editable (for now)
      return false if refl and (refl.macro == :has_many or refl.options[:polymorphic] or refl.macro == :has_one)
      
      if object.respond_to?(:editable_by?)
        check_permission(:edit, person, object, field.to_sym)
      else
        # Fake an edit test by setting the field in question to
        # Hobo::Undefined and then testing for update permission
        
        current = object.send(field)
        new = object.duplicate

        begin
          # Setting the undefined value can sometimes result in an
          # UndefinedAccessError. In that case we have no choice but
          # return false.
          new.send(setter, if current == true
                             false
                           elsif current == false
                             true
                           elsif refl and refl.macro == :belongs_to
                             Hobo::Undefined.new(refl.klass)
                           else
                             Hobo::Undefined.new
                           end)
        rescue Hobo::UndefinedAccessError
          raise HoboError, "#{object.class.name} does not support undefined assignements, define editable_by(user, field)"
        end
        
        begin
          if object.new_record?
            check_permission(:create, person, new)
          else
            check_permission(:update, person, object, new)
          end
        rescue Hobo::UndefinedAccessError
          false
        end
      end
    end


    def can_delete?(person, object)
      check_permission(:delete, person, object)
    end


    # can_view? has special behaviour if it's passed a class or an
    # association-proxy -- it instantiates the class, or creates a new
    # instance "in" the association (new_without_appending), and tests
    # the permission of this object. This means the permission methods
    # in models can't rely on the instance being properly initialised.
    # But it's important that it works like this because, in the case
    # of an association proxy, we don't want to loose the information
    # that the object belongs_to the proxy owner.
    def can_view?(person, object, field=nil)
      if field
        field = field.to_sym if field.is_a? String
        return false if object.is_a?(ActiveRecord::Base) and object.class.never_show?(field)
      else
        # Special support for classes (can view instances?)
        if object.is_a?(Class) and object < ActiveRecord::Base
          object = object.new
        elsif object.is_a?(Array)
          if object.respond_to?(:new_without_appending)
            object = object.new_without_appending
          elsif object.respond_to?(:member_class)
            object = object.member_class.new
          end          
        end
      end
      viewable = check_permission(:view, person, object, field)
      if viewable and field and
          ( (field_val = get_field(object, field)).is_a?(ActiveRecord::Base) or field_val.is_a?(Array) )
        # also ask the current value if it is viewable
        can_view?(person, field_val)
      else
        viewable
      end
    end
    
    
    def can_call?(person, object, method)
      return true if person.respond_to?(:super_user?) && person.super_user?

      m = "#{method}_callable_by?"
      object.respond_to?(m) && object.send(m, person)
    end 
    
    # --- end permissions -- #
    
    
    def static_tags
      @static_tags ||= begin
                         path = if FileTest.exists?("#{RAILS_ROOT}/config/dryml_static_tags.txt")
                                    "#{RAILS_ROOT}/config/dryml_static_tags.txt"
                                else
                                    File.join(File.dirname(__FILE__), "hobo/static_tags")
                                end
                         File.readlines(path).omap{chop} 
                       end
    end
    
    attr_writer :static_tags

    
    private


    def check_permission(permission, person, object, *args)
      return true if person.respond_to?(:super_user?) and person.super_user?
      
      return true if permission == :view && !(object.is_a?(ActiveRecord::Base) || object.is_a?(Hobo::CompositeModel))

      obj_method = case permission
                   when :create; :creatable_by?
                   when :update; :updatable_by?
                   when :delete; :deletable_by?
                   when :edit;   :editable_by?
                   when :view;   :viewable_by?
                   end
      p = if object.respond_to?(obj_method)
            begin
              object.send(obj_method, person, *args)
            rescue Hobo::UndefinedAccessError
              false
            end
          elsif object.class.respond_to?(obj_method)
            object.class.send(obj_method, person, *args)
          elsif !object.is_a?(Class) # No user fallback for class-level permissions
            person_method = "can_#{permission}?".to_sym
            if person.respond_to?(person_method)
              person.send(person_method, object, *args)
            else
              # The object does not define permissions - you can only view it
              permission == :view
            end
          end
    end

  end
  
  # --- Asset Publishing --- #
  

end
