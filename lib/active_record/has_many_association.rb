module ActiveRecord::Associations

  class HasManyAssociation

    alias_method :new, :build

    def new_without_appending(attributes = {})
      record = @reflection.klass.new(attributes)
      set_belongs_to_association_for(record)
      record
    end
    
    
    def include?(record)
      if loaded?
        target.include?(record)
      else
        find(record.id) && true rescue false
      end
    end

    
    def member_class
      proxy_reflection.klass
    end

  end

end

