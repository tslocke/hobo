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
          f =~ /.rb$/ and f.sub(/.rb$/, '').classify.constantize rescue nil
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

      _, name, id, attr = *dom_id.match(/^([a-z_]+)_([0-9]+)(_[a-z_]+)?$/)
      raise ArgumentError.new("invalid model-reference in dom id") unless name
      if name
        model_class = name.classify.constantize rescue (raise ArgumentError.new("no such class in dom-id"))
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
        raise HoboError.new("Tried to get field '#{attr}' of nil") if attr
        return 'nil'
      end

      if obj.is_a?(Array) and obj.respond_to?(:proxy_owner)
        attr = obj.proxy_reflection.name
        obj = obj.proxy_owner
      elsif !obj.is_a?(ActiveRecord::Base)
        if attr
          dom_id(get_field(obj, attr))
        else
          raise Exception.new("Can't create dom id for #{obj.inspect}")
        end
      end
      [obj.class.name.underscore, obj.id, attr].compact.join('_')
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
      begin
        ApplicationController
      rescue
        require "#{RAILS_ROOT}/app/controllers/application"
      end
      for model in Hobo.models
        web_name = model.name.underscore.pluralize.downcase
        controller = "#{model.name.pluralize}Controller".constantize rescue nil
        if controller and controller < Hobo::ModelController
          map.resources web_name, :collection => { :completions => :get }
          for refl in model.reflections.values.select {|r| r.macro == :has_many}
            map.named_route("#{web_name.singularize}_#{refl.name}",
                            "#{web_name}/:id/#{refl.name}",
                            :controller => web_name,
                            :action => "show_#{refl.name}",
                            :conditions => { :method => :get })

            map.named_route("new_#{web_name.singularize}_#{refl.name.to_s.singularize}",
                            "#{web_name}/:id/#{refl.name}/new",
                            :controller => web_name,
                            :action => "new_#{refl.name.to_s.singularize}")
            
            for method in controller.web_methods
              map.named_route("#{web_name.singularize}_#{method}",
                              "#{web_name}/:id/#{method}",
                              :controller => web_name,
                              :action => method.to_s,
                              :conditions => { :method => :post })
            end
            
            for method in controller.show_methods
              map.named_route("#{web_name.singularize}_#{method}",
                              "#{web_name}/:id;#{method}",
                              :controller => web_name,
                              :action => method.to_s,
                              :conditions => { :method => :get })
            end
            
          end
        end
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


    def can_create?(person, object)
      if object.is_a?(Class) and object < ActiveRecord::Base
        object = object.new
        object.created_by(person)
      elsif Hobo.simple_has_many_association?(object)
        object = object.new_without_appending
        object.created_by(person)
      end
      check_permission(:create, person, object)
    end


    def can_update?(person, object, new)
      check_permission(:update, person, object, new)
    end


    def can_edit?(person, object, field)
      return false unless can_view?(person, object, field)

      refl = object.class.reflections[field.to_sym] if object.is_a?(ActiveRecord::Base)
      
      # has_many and polymorphic associations are not editable (for now)
      return false if refl and (refl.macro == :has_many or refl.options[:polymorphic])

      new = object.duplicate
      new.send("#{field}=", if refl and refl.macro == :belongs_to
                              Hobo::Undefined.new(refl.klass)
                            else
                              Hobo::Undefined.new
                            end)

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


    def can_delete?(person, object)
      check_permission(:delete, person, object)
    end


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
      if viewable and field and (field_val = get_field(object, field)).is_a? ActiveRecord::Base
        # also ask the current value if it is viewable
        can_view?(person, field_val)
      else
        viewable
      end
    end
    
    
    def can_call?(person, object, method)
      return true if person.respond_to?(:super_user?) and person.super_user?

      m = "can_call_#{method}?"
      object.respond_to?(m) and object.send(m, current_user)
    end 

    
    private


    def check_permission(permission, person, object, *args)
      return true if person.respond_to?(:super_user?) and person.super_user?

      obj_method = case permission
                   when :create; :creatable_by?
                   when :update; :updatable_by?
                   when :delete; :deletable_by?
                   when :view;   :viewable_by?
                   end
      person_method = "can_#{permission}?".to_sym
      p = if object.respond_to?(obj_method)
            begin
              object.send(obj_method, person, *args)
            rescue Hobo::UndefinedAccessError
              false
            end
          elsif object.class.respond_to?(obj_method)
            object.class.send(obj_method, person, *args)
          elsif person.respond_to?(person_method)
            person.send(person_method, object, *args)
          else
            # The object does not define permissions - you can only view it
            permission == :view
          end
    end

  end

end
