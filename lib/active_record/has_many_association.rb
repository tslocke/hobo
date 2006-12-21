module ActiveRecord::Associations

  class HasManyAssociation

    alias_method :new, :build

    def include?(record)
      if loaded?
        target.include?(record)
      else
        find(record.id) && true rescue false
      end
    end

  end

end

