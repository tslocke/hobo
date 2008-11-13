module Hobo

  module Scopes

    def self.included_in_class(klass)
      klass.extend(ClassMethods)
    end

    module ClassMethods

      include AutomaticScopes

      include ApplyScopes

      # --- monkey-patches to allow :scope key on has_many, has_one and belongs_to ---

      def create_has_many_reflection(association_id, options, &extension)
        options.assert_valid_keys(
          :class_name, :table_name, :foreign_key,
          :dependent,
          :select, :conditions, :include, :order, :group, :limit, :offset,
          :as, :through, :source, :source_type,
          :uniq,
          :finder_sql, :counter_sql,
          :before_add, :after_add, :before_remove, :after_remove,
          :extend,
          :scope
        )

        options[:extend] = create_extension_modules(association_id, extension, options[:extend]) if block_given?

        create_reflection(:has_many, association_id, options, self)
      end

      def create_has_one_reflection(association_id, options)
        options.assert_valid_keys(
          :class_name, :foreign_key, :remote, :conditions, :order, :include, :dependent, :counter_cache, :extend, :as, :scope
        )

        create_reflection(:has_one, association_id, options, self)
      end

      def create_belongs_to_reflection(association_id, options)
        options.assert_valid_keys(
          :class_name, :foreign_key, :foreign_type, :remote, :conditions, :order, :include, :dependent,
          :counter_cache, :extend, :polymorphic, :scope
        )

        reflection = create_reflection(:belongs_to, association_id, options, self)

        if options[:polymorphic]
          reflection.options[:foreign_type] ||= reflection.class_name.underscore + "_type"
        end

        reflection
      end

    end

  end

end

ActiveRecord::Associations::AssociationProxy.send(:include, Hobo::Scopes::AssociationProxyExtensions)
ActiveRecord::Associations::HasManyThroughAssociation.send(:include, Hobo::Scopes::HasManyThroughAssociationExtensions)
require "hobo/scopes/named_scope_extensions"