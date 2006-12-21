module ActiveRecord::Associations

  class HasManyThroughAssociation

    def include?(record)
      if loaded?
        target.include?(record)
      else
        find(record.id) && true rescue false
      end
    end

  end

end

