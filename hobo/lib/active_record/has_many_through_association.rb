module ActiveRecord::Associations

  class HasManyThroughAssociation

    def member_class
      proxy_reflection.klass
    end
    
    def origin
      proxy_owner
    end

    def origin_attribute
      proxy_reflection.association_name
    end

  end

end

