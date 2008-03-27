# Add support for :scope => :my_scope to has_many and :belongs_to

module Hobo
  
  module Scopes
    
    module AssociationProxyExtensions
      
      def self.included(base)
        base.class_eval do 
          alias_method_chain :conditions, :hobo_scopes
        end
      end
      
      def conditions_with_hobo_scopes
        scope_conditions = if (scope_name = @reflection.options[:scope])
                             target_class = @reflection.klass
                             target_class.send(scope_name).scope(:find)[:conditions]
                           end
        if scope_conditions && conditions_without_hobo_scopes
          "(#{sanitize_sql conditions_without_hobo_scopes}) AND (#{sanitize_sql scope_conditions})"
        elsif scope_conditions
          sanitize_sql scope_conditions
        else
          conditions_without_hobo_scopes
        end
      end
      
    end
      
  end
  
end
