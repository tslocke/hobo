module Hobo
  
  class EnumString < String
    
    module Helper
      
      def enum_string(*values)
        EnumString.for(*values)
      end
      
    end
    
    class << self 
      
      def with_values(*values)
        @values = values.every(:to_s)
      end
      
      attr_accessor :values
      
      def for(*values)
        values = values.every(:to_s)
        c = Class.new(EnumString) do
          values.each do |v|
            define_method("#{v.underscore}?") { self == v }
            meta_def("#{v.underscore}") { v }
          end
        end
        c.with_values(*values)
        c
      end
      
      def inspect
        "#<EnumString #{(values || []) * ' '}>"
      end
      alias_method :to_s, :inspect
      
    end

    COLUMN_TYPE = :string
    
    def validate
      "must be one of #{self.class.values * ', '}" unless self.in? self.class.values
    end
    
  end
  
end

Hobo::FieldDeclarationsDsl.send(:include, Hobo::EnumString::Helper)
