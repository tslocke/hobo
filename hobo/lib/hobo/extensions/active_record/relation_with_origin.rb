module ActiveRecord

  class Relation
    attr_accessor :origin, :origin_attribute

    def member_class
      @klass
    end
  end

  module SpawnMethods
    def merge_with_origin(r)
      merged = merge_without_origin(r)
      # LH#1002:  cannot call respond_to? because default_scope ends
      # up calling merge and we end up with infinite recursion
      merged.origin = r.origin rescue nil unless merged.instance_variable_defined?("@origin")
      merged.origin_attribute = r.origin_attribute rescue nil unless merged.instance_variable_defined?("@origin_attribute")
      merged
    end

    alias_method_chain :merge, :origin
  end

  module Associations
    class CollectionProxy

      # FIXME Ralis4:  really hoping that we can replace this with
      # something based on https://github.com/rails/rails/issues/5717
      # def scoped_with_origin
      #   relation = scoped_without_origin.clone
      #   relation.origin = proxy_association.owner
      #   relation.origin_attribute = proxy_association.reflection.name
      #   relation
      # end
      # alias_method_chain :scoped, :origin

      def method_missing_with_origin(method, *args, &block)
        res = method_missing_without_origin(method, *args, &block)
        res.origin = proxy_association.owner if res.respond_to?(:origin)
        res.origin_attribute = proxy_association.reflection.name if res.respond_to?(:origin_attribute)
        res
      end
      alias_method_chain :method_missing, :origin

    end
  end
end
