module Hobo
  
  module Scopes
    
    class ScopeReflection < ActiveRecord::Reflection::AssociationReflection
      
      def initialize(macro, name, options, klass, association_name)
        super(macro, name, options, klass)
        @association_name = association_name
      end
      
      attr_accessor :association_name
      
    end

  end
  
end
