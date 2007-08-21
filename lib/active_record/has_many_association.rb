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
        set_reverse_association(record)
      end
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
    
    
    def find_with_block(*args, &b)
      if b
        options = extract_options_from_args!(args)
        args << options.merge(:conditions => member_class.conditions(&b))
        find_without_block(*args)
      else
        find_without_block(*args)
      end
    end
    alias_method_chain :find, :block
    
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

