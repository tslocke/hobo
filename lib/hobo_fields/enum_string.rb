module HoboFields
  
  class EnumString < String
    
    module DeclarationHelper
      
      def enum_string(*values)
        EnumString.for(*values)
      end
      
    end
    
    FieldDeclarationDsl.send(:include, DeclarationHelper)

    
    class << self 
      
      def with_values(*values)
        @values = values.*.to_s
      end
      
      attr_accessor :values
      
      def for(*values)
        values = values.*.to_s
        c = Class.new(EnumString) do
          values.each do |v|
            define_method("is_#{v.underscore}?") { self == v }
          end
        end
        c.with_values(*values)
        c
      end
      
      def inspect
        name.blank? ? "#<EnumString #{(values || []) * ' '}>" : name
      end
      alias_method :to_s, :inspect
      
    end

    COLUMN_TYPE = :string
    
    def validate
      "must be one of #{self.class.values * ', '}" unless self.in?(self.class.values)
    end
    
  end
  
end
