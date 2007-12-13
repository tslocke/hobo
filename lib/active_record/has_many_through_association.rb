module ActiveRecord::Associations

  class HasManyThroughAssociation

    def member_class
      proxy_reflection.klass
    end

  end

end

