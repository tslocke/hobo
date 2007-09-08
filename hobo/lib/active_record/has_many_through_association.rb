module ActiveRecord::Associations

  class HasManyThroughAssociation

    def include?(record)
      return false unless record.is_a? ActiveRecord::Base
      
      if loaded?
        target.include?(record)
      else
        !!find_by_id(record.id)
      end
    end
    
    def member_class
      proxy_reflection.klass
    end

  end

end

