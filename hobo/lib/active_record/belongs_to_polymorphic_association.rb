module ActiveRecord::Associations

  class BelongsToPolymorphicAssociation

    def origin
      proxy_owner
    end

    def origin_attribute
      proxy_reflection.name
    end
    
  end

end

