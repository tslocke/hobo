module HoboFields

  class SerializedObject < Object
    
    COLUMN_TYPE = :text
    
    def self.declared(model, name, options)
      model.serialize name, options.delete(:class)
    end
    
    HoboFields.register_type(:serialized, self)

  end

end
