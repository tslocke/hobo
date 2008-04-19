# Add support for :scope => :my_scope to has_many and :belongs_to

module Hobo
  
  module Scopes
    
    AssociationProxyExtensions = classy_module do
      
      def scope_conditions(reflection)
        scope_name = reflection.options[:scope] and
          target_class = reflection.klass and
          target_class.send(scope_name).scope(:find)[:conditions]
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
      
      def sql_conditions_with_hobo_scopes
        scope_conditions         = self.scope_conditions(@reflection)
        through_scope_conditions = self.scope_conditions(@reflection.through_reflection)
        unscoped_conditions = sql_conditions_without_hobo_scopes
        combine_conditions(scope_conditions, through_scope_conditions, unscoped_conditions)
      end

      alias_method_chain :sql_conditions, :hobo_scopes
      
    end
      
  end
  
end
