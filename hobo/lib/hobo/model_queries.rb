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
    
    
    def sql(s)
      WhereFragment.new(s)
    end
    
    def block(b)
      b && instance_eval(&b)
    end
    
    
    def all?(*args)
      args.inject { |m, a| m & a }
    end

    def any?(*args)
      args.inject { |m, a| m | a }
    end

    def method_missing(name, *args)
      check_column = proc do |col|
        raise HoboError.new("no such column '#{col}' in query") unless
          model.columns.every(:name).include? col
      end

      m, field = *name.to_s.match(/^(.*)_is$/)
      if m
        if (refl = model.reflections[field.to_sym]) && refl.macro == :belongs_to
          field = refl.primary_key_name
          val = args[0] && args[0].id
          raise HoboError.new("don't use self in query blocks") if val == self
        else 
          check_column[field]
          val = args[0]
        end
        return (if val.nil?
                  WhereFragment.new("#{_query_table}.#{field} IS NULL")
                else
                  WhereFragment.new("#{_query_table}.#{field} = ?", val)
                end)
      end

      m, field = *name.to_s.match(/^(.*)_contains$/)
      if m
        check_column[field]
        return WhereFragment.new("#{_query_table}.#{field} like ?", "%#{args[0]}%")
      end

      m, field = *name.to_s.match(/^(.*)_starts$/)
      if m
        check_column[field]
        return WhereFragment.new("#{_query_table}.#{field} like ?", "#{args[0]}%")
      end

      m, field = *name.to_s.match(/^(.*)_ends$/)
      if m
        check_column[field]
        return WhereFragment.new("#{_query_table}.#{field} like ?", "%#{args[0]}")
      end
      
      if (refl = model.reflections[name.to_sym]) && refl.macro == :belongs_to
        return ModelQueries.new(refl.klass)
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
    
    def _query_table
      model.table_name
    end

  end

end
