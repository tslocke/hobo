module ActiveRecord
  module Associations
    class AssociationProxy #:nodoc:
      
      private
      
      
      def raise_on_type_mismatch(record)
        # Don't complain if the interface type of a polymorphic association doesn't exist
        klass = @reflection.klass rescue nil
        unless klass.nil? || record.is_a?(klass)
          raise ActiveRecord::AssociationTypeMismatch, "#{@reflection.klass} expected, got #{record.class}"
        end
      end
        
    end
  end
end
