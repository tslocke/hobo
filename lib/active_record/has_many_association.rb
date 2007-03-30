module ActiveRecord::Associations

  class HasManyAssociation

    def new
      res = build
      if @owner.new_record?
        refl = @owner.class.reverse_reflection(@reflection.name)
        if refl
          bta = ActiveRecord::Associations::BelongsToAssociation.new(res, refl)
          bta.replace(@owner)
          res.instance_variable_set("@#{refl.name}", bta)
        end
      end
      res
    end

    def new_without_appending(attributes = {})
      record = @reflection.klass.new(attributes)
      set_belongs_to_association_for(record)
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
    
  end

end

