require 'hobo_fields/field_declaration_dsl'

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
            const_name = v.upcase.gsub(/[^a-z0-9_]/i, '_').gsub(/_+/, '_')
            const_set(const_name, self.new(v)) unless const_defined?(const_name)

            method_name = "is_#{v.underscore}?"
            define_method(method_name) { self == v } unless self.respond_to?(method_name)
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

    def ==(other)
      if other.is_a?(Symbol)
        super(other.to_s)
      else
        super
      end
    end

  end

end
