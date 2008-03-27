module ActiveRecord::Associations

  class HasManyAssociation
    
    def hobo_has_many?
      Hobo::Model.in?(@owner.class.included_modules)
    end

    def build_with_reverse_reflection(*args)
      res = build_without_reverse_reflection(*args)
      set_reverse_association(res) if hobo_has_many?
      res
    end
    alias_method_chain :build, :reverse_reflection
    

    def new(attributes = {})
      record = @reflection.klass.new(attributes)
      if hobo_has_many?
        set_belongs_to_association_for(record)
        set_reverse_association(record) unless proxy_reflection.options[:as]
      end
      record
    end
    
    
    def member_class
      proxy_reflection.klass
    end
    
    
    def origin
      proxy_owner
    end

    
    def origin_attribute
      proxy_reflection.association_name
    end
    
    
    private
    
    def set_reverse_association(object)
      if @owner.new_record? && (refl = @owner.class.reverse_reflection(@reflection.name))
        bta = ActiveRecord::Associations::BelongsToAssociation.new(object, refl)
        bta.replace(@owner)
        object.instance_variable_set("@#{refl.name}", bta)
      end      
    end
    
  end

end

