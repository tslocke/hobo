module Hobo::PredicateDispatch
  
  def self.included(base)
    puts base
    base.extend(ClassMethods)
  end
  
  module ClassMethods
    
    def defp(name, predicate=nil, &block)
      ivar = "@#{name}_predicates"
      default_method_name = "_default_#{name}".to_sym
      methods = instance_variable_get(ivar)

      if methods.nil?
        # It's the first defp for this name...

        methods = instance_variable_set(ivar, [])
        
        if name.to_s.in?(instance_methods) and predicate
          # There's already a normal method with this name - it
          # becomes the default.
          alias_method default_method_name, name
        end
        
      end
      
      if predicate
        pname = "#{name}_p#{methods.length}"
        methods << [predicate, pname, block.arity == 2]
        define_method(pname, block)
      else
        # It's the default - if there's already one, overwrite it
        define_method(default_method_name, block)
      end
      
      module_eval %{
        def #{name}(options={}, &block)
          methods = self.class.instance_variable_get('#{ivar}')
          for predicate, method_name, wants_block in methods
            if Hobo::ProcBinding.new(self, options).instance_eval(&predicate)
              return (if wants_block
                        send(method_name, options, block)
                      else
                        send(method_name, options) 
                      end)
            end
          end
          if respond_to?(:#{default_method_name})
            if method(:#{default_method_name}).arity == 2
               #{default_method_name}(options, block) 
            else
               #{default_method_name}(options) 
            end
          end
        end
      }
    end
    
    alias :p :proc
    
    def predicate_method?(method_name)
      instance_variable_get("@#{method_name}_predicates") and true
    end
    
  end
  
  
end
