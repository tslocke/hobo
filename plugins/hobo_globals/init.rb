module ::Hobo::Plugins

  class HoboGlobals
    
    def initialize(options={}, &b)
      options = options.reverse_merge(:model => "Globals", :table_name => "globals")
      hobo_model options[:model] do
        set_table_name options[:table_name]
        fields(&b)
        
        class << self
          
          def instance
            @instance ||= (find(:first) || create)
          end
          
          def method_missing(name, *args)
            instance.send(name, *args)
          end
          
        end
      end
    end
    
  end
  
end
