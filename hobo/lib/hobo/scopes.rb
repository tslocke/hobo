module Hobo

  module Scopes

    def self.included_in_class(klass)
      klass.class_eval do
        extend ClassMethods
        metaclass.alias_method_chain :valid_keys_for_has_many_association,   :scopes
        metaclass.alias_method_chain :valid_keys_for_has_one_association,    :scopes
        metaclass.alias_method_chain :valid_keys_for_belongs_to_association, :scopes
      end
    end

    module ClassMethods

      include AutomaticScopes

      include ApplyScopes

      # --- monkey-patches to allow :scope key on has_many, has_one and belongs_to ---
      
      def valid_keys_for_has_many_association_with_scopes
        valid_keys_for_has_many_association_without_scopes + [:scope]
      end

      def valid_keys_for_has_one_association_with_scopes
        valid_keys_for_has_one_association_without_scopes + [:scope]
      end

      def valid_keys_for_belongs_to_association_with_scopes
        valid_keys_for_belongs_to_association_without_scopes + [:scope]
      end

    end

  end

end

ActiveRecord::Associations::AssociationProxy.send(:include, Hobo::Scopes::AssociationProxyExtensions)
ActiveRecord::Associations::AssociationCollection.send(:include, Hobo::Scopes::AssociationCollectionExtensions)
ActiveRecord::Associations::HasManyThroughAssociation.send(:include, Hobo::Scopes::HasManyThroughAssociationExtensions)
require "hobo/scopes/named_scope_extensions"