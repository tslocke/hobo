# Add support for :scope => :my_scope to has_many and :belongs_to

module Hobo
  
  module Scopes
    
    AssociationProxyExtensions = classy_module do
      
      def conditions_with_hobo_scopes
        scope_conditions = if (scope_name = @reflection.options[:scope])
                             target_class = @reflection.klass
                             target_class.send(scope_name).scope(:find)[:conditions]
                           end
        unscoped_conditions = conditions_without_hobo_scopes
        if scope_conditions && unscoped_conditions
          "(#{sanitize_sql conditions_without_hobo_scopes}) AND (#{sanitize_sql scope_conditions})"
        elsif scope_conditions
          sanitize_sql scope_conditions
        else
          unscoped_conditions
        end
      end

      alias_method_chain :conditions, :hobo_scopes
      
    end

    # Horrible repitition, but you know what, sometimes you just do.
    
    HasManyThroughAssociationExtensions = classy_module do
      
      def sql_conditions_with_hobo_scopes
        scope_conditions = if (scope_name = @reflection.options[:scope])
                             target_class = @reflection.klass
                             target_class.send(scope_name).scope(:find)[:conditions]
                           end
        unscoped_conditions = sql_conditions_without_hobo_scopes
        if scope_conditions && unscoped_conditions
          "(#{sanitize_sql conditions_without_hobo_scopes}) AND (#{sanitize_sql scope_conditions})"
        elsif scope_conditions
          sanitize_sql scope_conditions
        else
          unscoped_conditions
        end
      end

      alias_method_chain :sql_conditions, :hobo_scopes
      
    end
      
  end
  
end
