module Hobo::PredicateDispatch
  
  def self.included(base)
    base.extend(ClassMethods)
  end
  
  module ClassMethods
    
    def default_method_for(method)
      "_default_#{method}"
    end
    
    def defp(name, predicate=nil, &block)
      ivar = "@@#{name}_predicates"
      default_method_name = default_method_for(name).to_sym
      methods = ivar.in?(class_variables) && class_variable_get(ivar)

      if !methods
        # It's the first defp for this name...

        methods = class_variable_set(ivar, [])
        
        if name.to_s.in?(instance_methods) and predicate
          # There's already a normal method with this name - it
          # becomes the default.
          alias_method default_method_name, name
        end
        
      end
      
      if predicate
        pname = "#{name}_p#{methods.length}"
        methods << [pname, predicate.arity == 1, block.arity == 2]
        define_method(pname, block)
        define_method(pname + "_predicate", &predicate)
      else
        # It's the default - if there's already one, overwrite it
        define_method(default_method_name, block)
      end
      
      module_eval <<-END, __FILE__, __LINE__+1
        def #{name}(options={}, &block)
          methods = #{ivar}
          for method_name, predicate_wants_options, wants_block in methods
            pred = method_name + "_predicate"
            if (predicate_wants_options ? send(pred, options) : send(pred))
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
      END
    end
    
    alias :p :proc
    
    def predicate_method?(method_name)
      "@@#{method_name}_predicates".in?(class_variables)
    end
    
    def predicate_has_default?(method_name)
      default_method_for(method_name).in?(instance_methods)
    end
    
  end
  
  
end
