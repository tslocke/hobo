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
          "#{conditions_without_hobo_scopes} AND #{scope_conditions}"
        else
          scope_conditions || conditions_without_hobo_scopes
        end
      end
      
    end
      
  end
  
end
