module Hobo::Plugins
  class << self
  
    def make_hobo_model(name, &b)
      make_class name, ActiveRecord::Base do
        hobo_model
        class_eval &b if b
      end
    end      

    def make_resource_controller(name, &b)
      controller_name = "#{name.to_s.pluralize}Controller".to_sym
      
      make_class controller_name, ApplicationController do
        hobo_model_controller
        class_eval &b if b
      end
    end
  
    def make_class(class_name, base_class, &b)
      c = Class.new(base_class)
      silence_warnings {Object.const_set(class_name, c)}
      c.class_eval(&b) if b
      c
    end
  
  end
    
end