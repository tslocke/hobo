plugin_model :Globals do 
  
  set_table_name _table_name_

  fields(&_fields_)
    
  class << self
      
    def instance
      @instance ||= (find(:first) || create)
    end
      
    def method_missing(name, *args)
      instance.send(name, *args)
    end
      
  end
end
