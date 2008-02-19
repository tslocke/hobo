module Hobo

  module Scopes
    
    module DefinedScopeProxyExtender
      
      attr_accessor :reflections
      
      def method_missing(name, *args, &block)
        if (scope = named_scope(name))
          association_proxy_for_scope(name, scope, *args)
        else
          super
        end
      end
      
      
      def named_scope(name)
        proxy_reflection.klass.try.defined_scopes._?[name.to_sym]
      end
      
      
      def association_proxy_for_scope(name, scope, args)
        scope_name = "@#{name.to_s.gsub('?','')}_scope"

        # Calling instance_variable_get or set directly causes self to
        # get loaded, hence the 'bind' tricks
        
        Kernel.instance_method(:instance_variable_get).bind(self).call(scope_name) or
          begin
            scope = scope.call(*args) if scope.is_a?(Proc)
            assoc = create_association_proxy_for_scope(name, scope)
            Kernel.instance_method(:instance_variable_set).bind(self).call(scope_name, assoc)
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

        r = ScopeReflection.new(:has_many, name, options, proxy_owner.class, proxy_reflection.name)
        
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
