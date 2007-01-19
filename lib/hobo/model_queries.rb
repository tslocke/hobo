module Hobo

  class ModelQueries

    def initialize(model)
      @model = model
    end


    attr_reader :model

    def not_(fragment)
      WhereFragment.new("not (#{fragment.to_sql})")
    end


    def is_in(association)
      association = Hobo.object_from_dom_id(association) if association.is_a? String
      refl = association.proxy_reflection
      raise HoboError.new("association #{refl.name} is not a collection of #{model.name.pluralize}") unless
        refl.klass == model and refl.macro == :has_many

      WhereFragment.new(_association_finder_sql(association))
    end
    
    
    def not_in(association)
      not_(is_in(association))
    end


    def method_missing(name, *args)
      check_column = proc do |col|
        raise HoboError.new("no such column '#{col}' in query") unless
          model.columns.every(:name).include? col
      end

      m, field = *name.to_s.match(/^(.*)_is$/)
      if m
        check_column[field]
        return WhereFragment.new("#{field}", args[0])
      end

      m, field = *name.to_s.match(/^(.*)_contains$/)
      if m
        check_column[field]
        return WhereFragment.new("#{field} like ?", "%#{args[0]}%")
      end

      m, field = *name.to_s.match(/^(.*)_starts$/)
      if m
        check_column[field]
        return WhereFragment.new("#{field} like ?", "#{args[0]}%")
      end

      m, field = *name.to_s.match(/^(.*)_ends$/)
      if m
        check_column[field]
        return WhereFragment.new("#{field} like ?", "%#{args[0]}")
      end

      return WhereFragment.new(@model.send(name, *args))
    end

    def _association_finder_sql(assoc)
      refl = assoc.proxy_reflection
      if refl.through_reflection
        conditions = assoc.send(:construct_conditions)
        from       = assoc.send(:construct_from)
        joins      = assoc.send(:construct_joins)

        table = "#{model.table_name}"
        "id in (select #{table}.id from #{table} #{joins} where #{conditions})"
      else
        Object.instance_method(:instance_variable_get).bind(assoc).call("@finder_sql")
      end
    end

  end

end
