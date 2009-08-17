# Add support for :scope => :my_scope to has_many and belongs_to

module Hobo

  module Scopes

    AssociationProxyExtensions = classy_module do

      def scope_conditions(reflection)
        scope_name = reflection.options[:scope]
        return nil if scope_name.nil?
        target_class = reflection.klass
        return nil if target_class.nil?
        if scope_name.respond_to? :map
          combine_conditions(*(scope_name.map {|scope| target_class.send(*scope).scope(:find)[:conditions]}))
        else
          target_class.send(scope_name).scope(:find)[:conditions]
        end
      end


      def combine_conditions(*conditions)
        parts = conditions.compact.map { |c| "(#{sanitize_sql c})" }
        parts.empty? ? nil : parts.join(" AND ")
      end


      def conditions_with_hobo_scopes
        scope_conditions = self.scope_conditions(@reflection)
        unscoped_conditions = conditions_without_hobo_scopes
        combine_conditions(scope_conditions, unscoped_conditions)
      end
      alias_method_chain :conditions, :hobo_scopes

    end

    HasManyThroughAssociationExtensions = classy_module do

      def build_conditions_with_hobo_scopes
        scope_conditions         = self.scope_conditions(@reflection)
        through_scope_conditions = self.scope_conditions(@reflection.through_reflection)
        unscoped_conditions = build_conditions_without_hobo_scopes
        combine_conditions(scope_conditions, through_scope_conditions, unscoped_conditions)
      end
      alias_method_chain :build_conditions, :hobo_scopes
      public :conditions
      
    end
    
    AssociationCollectionExtensions = classy_module do
      
      def proxy_respond_to_with_automatic_scopes?(method, include_priv = false)
        proxy_respond_to_without_automatic_scopes?(method, include_priv) ||
          (@reflection.klass.create_automatic_scope(method) if @reflection.klass.respond_to?(:create_automatic_scope))
      end
      alias_method_chain :proxy_respond_to?, :automatic_scopes
      
    end

  end

end
