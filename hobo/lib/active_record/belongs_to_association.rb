module ActiveRecord::Associations

  class BelongsToAssociation

    def origin
      proxy_owner
    end

    def origin_attribute
      proxy_reflection.name
    end
    
  end

end

