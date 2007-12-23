module ::Hobo::Plugins

  class HoboGlobals < Hobo::Plugin
    
    def defaults
      { :table_name => "globals" }
    end
    
  end
  
end
