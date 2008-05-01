module Hobo

  module Scopes
    
    module DefinedScopeProxyExtender
      
      attr_accessor :reflections
      
      include AutomaticScopes
      
      include ApplyScopes
      
      def method_missing(name, *args, &block)
        if (scope = named_scope(name))
          association_proxy_for_scope(name, scope, args)
        elsif member_class.try.create_automatic_scope(name)
          # create_automatic_scope returned true -- the method now exists
          send(name, *args, &block)
        else
          super
        end
      end
      
      
      def named_scope(name)
        proxy_reflection.klass.try.defined_scopes._?[name.to_sym]
      end
      
      
      def association_proxy_for_scope(name, scope_or_proc, args)
        if scope_or_proc.is_a?(Proc)
          scope = scope_or_proc.call(*args)
          create_association_proxy_for_scope(name, scope)
        else
          # This scope is not parameterised so we can cache the
          # association-proxy in an instance variable
          scope = scope_or_proc
          scope_ivar = "@#{name.to_s.gsub('?','')}_scope"
          
          # Some craziness here -- calling instance_variable_get or
          # set directly causes self to get loaded, hence the 'bind'
          # tricks
          Kernel.instance_method(:instance_variable_get).bind(self).call(scope_ivar) or
            begin
              assoc = create_association_proxy_for_scope(name, scope)
              Kernel.instance_method(:instance_variable_set).bind(self).call(scope_ivar, assoc)
            end
        end
      end
      
      
      def create_association_proxy_for_scope(name, scope)
        options = proxy_reflection.options
        has_many_conditions = options[:conditions]
        has_many_conditions = nil if has_many_conditions.blank?
        source = proxy_reflection.source_reflection
        scope_conditions = scope[:conditions]
        scope_conditions = nil if scope_conditions.blank?
        conditions = if has_many_conditions && scope_conditions
                       "(#{sanitize_sql scope_conditions}) AND (#{sanitize_sql has_many_conditions})"
                     else
                       scope_conditions || has_many_conditions
                     end
        
        options = options.merge(scope).update(:class_name => proxy_reflection.klass.name,
                                              :foreign_key => proxy_reflection.primary_key_name)
        options[:conditions] = conditions unless conditions.blank?
        options[:source] = source.name if source
        
        options[:limit]   = scope[:limit]   if scope[:limit]
        options[:order]   = scope[:order]   if scope[:order]
        options[:include] = scope[:include] if scope[:include]

        r = ScopeReflection.new(:has_many, name, options, proxy_owner.class, proxy_reflection.association_name)
        
        @reflections ||= {}
        @reflections[name] = r
        
        if source
          ActiveRecord::Associations::HasManyThroughAssociation
        else
          ActiveRecord::Associations::HasManyAssociation
        end.new(proxy_owner, r)
      end
   
    end
    
  end      

end
