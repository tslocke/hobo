module ActiveRecord

  class Relation
    attr_accessor :origin, :origin_attribute
  end

  module Associations
    class AssociationCollection

      def scoped_with_origin
        relation = scoped_without_origin.clone
        relation.origin = @owner
        relation.origin_attribute = @reflection.name
        relation
      end
      alias_method_chain :scoped, :origin

      def method_missing_with_origin(method, *args, &block)
        res = method_missing_without_origin(method, *args, &block)
        res.origin = @owner if res.respond_to?(:origin)
        res.origin_attribute = @reflection.name if res.respond_to?(:origin_attribute)
        res
      end
      alias_method_chain :method_missing, :origin

    end
  end
end
