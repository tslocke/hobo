class HoboError < RuntimeError; end

module Hobo

  class RawJs < String; end

  @models = []

  class << self

    attr_accessor :current_theme, :guest_user
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
      @models.every(:constantize)
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
      else
        raise Exception.new("Can't create dom id for #{obj.inspect}") unless
          obj.is_a?(ActiveRecord::Base)
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
      result = []
      for type, ids in records
        result.concat(type.constantize.find(:all, :conditions => "id in (#{ids * ','})"))
      end
      result
    end

    def add_routes(map)
      for model in Hobo.models
        controller = model.name.underscore.pluralize
        map.resources controller, :collection => { :completions => :get }
        for refl in model.reflections.values.select {|r| r.macro == :has_many}
          map.named_route("#{controller.singularize}_#{refl.name}",
                          "#{controller}/:id/#{refl.name}",
                          :controller => controller,
                          :action => "show_#{refl.name}",
                          :conditions => { :method => :get })

          map.named_route("new_#{controller.singularize}_#{refl.name.to_s.singularize}",
                          "#{controller}/:id/#{refl.name}/new",
                          :controller => controller,
                          :action => "new_#{refl.name.to_s.singularize}")
        end
      end
    end


    def all_controllers
      Hobo.models.map {|m| m.name.underscore.pluralize}
    end


    def simple_has_many_association?(array_or_reflection)
      refl = array_or_reflection.is_a?(Array) ? array_or_reflection.proxy_reflection : array_or_reflection
      refl.macro == :has_many and
        (not refl.through_reflection) and
        (not refl.options[:conditions])
    end


    def can_create?(person, object)
      if object.is_a?(Class) and object < ActiveRecord::Base
        object = object.new
        object.created_by(person)
      end
      check_persmission(:create, person, object)
    end


    def can_update?(person, object, new)
      check_persmission(:update, person, object, new)
    end


    def can_edit?(person, object, field)
      return false unless can_view?(person, object, field)

      refl = object.class.reflections[field.to_sym] if object.is_a?(ActiveRecord::Base)

      x = if refl
            # has_many associations are not editable
            return false if refl.macro == :has_many

            Hobo::Undefined.new(refl.klass)
          else
            Hobo::Undefined.new
          end

      new = object.duplicate
      new.send(:"#{field}=", x)

      begin
        if object.new_record?
          check_persmission(:create, person, new)
        else
          check_persmission(:update, person, object, new)
        end
      rescue UndefinedAccessError
        false
      end
    end


    def can_delete?(person, object)
      check_persmission(:delete, person, object)
    end


    def can_view?(person, object, field)
      return false if field and object.is_a?(ActiveRecord::Base) and object.class.never_show?(field)
      check_persmission(:view, person, object, field && field.to_sym)
    end

    private


    def check_persmission(permission, person, object, *args)
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
          elsif person.respond_to?(person_method)
            person.send(person_method, object, *args)
          else
            permission == :view
          end
    end

  end

end
