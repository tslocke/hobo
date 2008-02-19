module HoboFields
  
  FieldsDeclaration = classy_module do 
    
    def self.fields(&b)
      # Any model that calls 'fields' gets a bunch of other
      # functionality included automatically
      include HoboFields::ModelExtensions
      
      dsl = FieldDeclarationDsl.new(self)
      if b.arity == 1
        yield dsl
      else
        dsl.instance_eval(&b)
      end
    end
    
  end

end
