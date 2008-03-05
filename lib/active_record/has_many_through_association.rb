module ActiveRecord::Associations

  class HasManyThroughAssociation

    def member_class
      proxy_reflection.klass
    end

    def association_name
      proxy_reflection.association_name
    end

  end

end

