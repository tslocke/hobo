module Hobo
  
  module Scopes
    
    class ScopedProxy
      
      def initialize(klass, scope)
        @klass = klass
        
        # If there's no :find, or :create specified, assume it's a find scope
        @scope = if scope.has_key?(:find) || scope.has_key?(:create)
                   scope
                 else
                   { :find => scope }
                 end
      end
      
      
      def method_missing(name, *args, &block)
        if name.to_sym.in?(@klass.defined_scopes.keys)
          proxy = @klass.send(name, *args)
          proxy.instance_variable_set("@parent_scope", self)
          proxy
        else
          _apply_scope { @klass.send(name, *args, &block) }
        end
      end
      
      def all
        self.find(:all)
      end
      
      def first
        self.find(:first)
      end
      
      def member_class
        @klass
      end
      
      private
      def _apply_scope
        if @parent_scope
          @parent_scope.send(:_apply_scope) do
            @scope ? @klass.send(:with_scope, @scope) { yield } : yield
          end
        else
          @scope ? @klass.send(:with_scope, @scope) { yield } : yield
        end
      end
      
    end
    (Object.instance_methods + 
     Object.private_instance_methods +
     Object.protected_instance_methods).each do |m|
      ScopedProxy.send(:undef_method, m) unless
        m.in?(%w{initialize method_missing send instance_variable_set instance_variable_get puts}) || m.starts_with?('_')
      
    end
    
  end
  
end
