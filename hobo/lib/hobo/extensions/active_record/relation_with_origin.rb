module ActiveRecord

  class Relation
    attr_accessor :origin, :origin_attribute

    def member_class
      @klass
    end
  end

  module Associations
    class CollectionProxy

      def scoped_with_origin
        relation = scoped_without_origin.clone
        relation.origin = proxy_association.owner
        relation.origin_attribute = proxy_association.reflection.name
        relation
      end
      alias_method_chain :scoped, :origin

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
