module Hobo
  
  class ViewHints
  
    def self.setter(name, default=nil, &block)
      metaclass.send :define_method, name do |*args|
        if args.empty?
          instance_variable_get("@#{name}") || default
        else 
          arg = if block
                  block[*args] 
                else
                  args.first
                end
          instance_variable_set("@#{name}", arg)
        end
      end
    end
  
    setter :model_name
    
    setter :field_names, {}
    
    setter :field_help,  {}
    
    setter :children,    [] do |*args|
      args
    end
    
    # Accessors
    
    class << self
      
      def model_name
        name.sub(/Hints$/, "")
      end

      def model
        @model ||= model_name.constantize
      end

      def field_name(field)
        field_names.fetch(field.to_sym, field.to_s.titleize)
      end
    
      def primary_children
        children.first || model.dependent_collections.sort_by(&:to_s).first
      end
      
      def secondary_children
        children.rest
      end
      
    end
    
  end
  
end    
