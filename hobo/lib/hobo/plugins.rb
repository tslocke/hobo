module ::Hobo::Plugins
  class HoboPlugin

    def initialize(opt={})
      @opt = opt
      set_up_options(self.class::PLUGIN_DEFAULTS)

      send @opt[:setup_using] || :default
    end

    def set_up_options(*defaults)
      @opt = @opt.reverse_merge(*defaults)
      make_variations(self.class::PLUGIN_SYMBOLS)
    end

    def make_variations(h)
      h.each do |name|
        if @opt[name] && @opt[name] != false
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
        else
          @opt[name.to_s.pluralize.to_sym] = false
        end
      end
    end

    def hobo_model(name, &b)
      make_class(@opt ? @opt[name] : name, ActiveRecord::Base) do
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
      opt = @opt
      c = Class.new(base_class)
      silence_warnings { Object.const_set(class_name, c) }
      c.class_eval do
        @plugin_opt = opt
        def self.sym
          @plugin_opt
        end
        def self.has_feature(name)
          @plugin_opt[name]
        end
        def sym
          self.class.sym
        end
      end
      c.class_eval &b if b
      c
    end
    
  end    
end
