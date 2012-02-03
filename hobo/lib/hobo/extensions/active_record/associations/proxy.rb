module ActiveRecord
  module Associations
    class CollectionProxy #:nodoc:
      def origin
        proxy_association.owner
      end

      def origin_attribute
        proxy_association.reflection.name
      end
    end
  end
end
