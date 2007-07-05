module ::Hobo::Plugins
  class HoboPlugin

    def initialize(opt=nil)
      @opt = opt || Hash.new
      set_up_options(self.class::PLUGIN_DEFAULTS)

      if @opt[:setup_using]
        send @opt[:setup_using]
      else
        default
      end
    end

    def set_up_options(*defaults)
      @opt.reverse_merge!(*defaults)
      make_variations(self.class::PLUGIN_SYMBOLS)
    end

    def make_variations(h)
      h.each do |name|
        if @opt[name]
          # start with :product_category
        
          # add :product_categories
          @opt[name.to_s.pluralize.to_sym] = @opt[name].to_s.pluralize.to_sym 

          # :ProductCategory
          @opt[name.to_s.camelize.to_sym] = @opt[name].to_s.camelize.to_sym 

          # :ProductCategories
          @opt[name.to_s.camelize.pluralize.to_sym] = @opt[name].to_s.camelize.pluralize.to_sym 
        
          # :ProductCategoriesController
          @opt[(name.to_s.camelize.pluralize+'Controller').to_sym] =
            (@opt[name].to_s.camelize.pluralize+'Controller').to_sym
        end
      end
    end

    def hobo_model(name, &b)
      make_class @opt[name], ActiveRecord::Base do
        hobo_model
        class_eval &b if b
      end
    end

    def resource_controller(name, &b)
      make_class @opt[name], ApplicationController do
        hobo_model_controller
        class_eval &b if b
      end
    end
  
    def make_class(class_name, base_class, &b)
      c = Class.new(base_class)
      silence_warnings { Object.const_set(class_name, c) }
      c.class_eval(&b) if b
      c
    end
    
  end    
end
