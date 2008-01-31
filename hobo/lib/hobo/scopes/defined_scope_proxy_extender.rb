module Hobo

  module Scopes
    
    module DefinedScopeProxyExtender
      
      attr_accessor :reflections
      
      def method_missing(name, *args, &block)
        if (scope = finder_scope(name, *args))
          association_proxy_for_scope(name, scope)
        else
          super
        end
      end
      
      
      def finder_scope(name, *args)
        scope = (proxy_reflection.klass.respond_to?(:defined_scopes) and
                 scopes = proxy_reflection.klass.defined_scopes and
                 scopes[name.to_sym])
        
        scope = scope.call(*args) if scope.is_a?(Proc)
        
        # If there's no :find, or :create specified, assume it's a find scope
        if scope && (scope.has_key?(:find) || scope.has_key?(:create))
          scope[:find]
        else
          scope
        end
      end
      
      
      def association_proxy_for_scope(name, find_scope)
        scope_name = "@#{name.to_s.gsub('?','')}_scope"

        # Calling instance_variable_get or set directly causes self to
        # get loaded, hence the 'bind' tricks
        
        Kernel.instance_method(:instance_variable_get).bind(self).call(scope_name) or
          begin
            assoc = create_association_proxy_for_scope(name, find_scope)
            Kernel.instance_method(:instance_variable_set).bind(self).call(scope_name, assoc)
          end
      end
      
      
      def create_association_proxy_for_scope(name, find_scope)
        options = proxy_reflection.options
        has_many_conditions = options[:conditions]
        has_many_conditions = nil if has_many_conditions.blank?
        source = proxy_reflection.source_reflection
        scope_conditions = find_scope[:conditions]
        scope_conditions = nil if scope_conditions.blank?
        conditions = if has_many_conditions && scope_conditions
                       "(#{sanitize_sql scope_conditions}) AND (#{sanitize_sql has_many_conditions})"
                     else
                       scope_conditions || has_many_conditions
                     end
        
        options = options.merge(find_scope).update(:class_name => proxy_reflection.klass.name,
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
