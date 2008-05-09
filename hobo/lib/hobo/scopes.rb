%w[apply_scopes association_proxy_extensions automatic_scopes defined_scope_proxy_extender scope_reflection scoped_proxy].each do |lib|
  require "hobo/scopes/#{lib}"
end

module Hobo

  module Scopes

    def self.included_in_class(base)
      base.extend(ClassMethods)

      class << base
        alias_method_chain :has_many, :defined_scopes
      end
    end

    module ClassMethods

      include AutomaticScopes

      include ApplyScopes

      def defined_scopes
        @defined_scopes ||= {}
      end


      def def_scope(name, scope=nil, &block)
        defined_scopes[name.to_sym] = block || scope

        meta_def(name) do |*args|
          ScopedProxy.new(self, block ? block.call(*args) : scope)
        end
      end


      def apply_scopes(scopes)
        result = self
        scopes.each_pair do |scope, arg|
          if arg.is_a?(Array)
            result = result.send(scope, *arg) unless arg.first.blank?
          else
            result = result.send(scope, arg) unless arg.blank?
          end
        end
        result
      end


      def alias_scope(new_name, old_name)
        metaclass.send(:alias_method, new_name, old_name)
        defined_scopes[new_name] = defined_scopes[old_name]
      end


      def has_many_with_defined_scopes(name, options={}, &block)
        if options.has_key?(:extend) || block
          # Normal has_many
          has_many_without_defined_scopes(name, options, &block)
        else
          options[:extend] = Hobo::Scopes::DefinedScopeProxyExtender
          has_many_without_defined_scopes(name, options, &block)
        end
      end


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
