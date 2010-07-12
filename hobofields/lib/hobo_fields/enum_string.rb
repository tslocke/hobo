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
        @translated_values = Hash.new do |hash, value|
          if name.blank? || value.blank?
            hash[value] = value
          else
            hash[value] = I18n.t("#{name.tableize}.#{value}", :default => value)
            @detranslated_values[hash[value]] = value
            hash[value]
          end
        end
            
        @detranslated_values = Hash.new do |hash, value|
          if name.blank?
            hash[value] = value
          else
            hash[value] = @values.detect(proc { value } ) {|v|
              @translated_values[v]==value
            }
          end
        end
      end

      attr_accessor :values

      attr_accessor :translated_values

      attr_accessor :detranslated_values

      def for(*values)
        options = values.extract_options!
        values = values.*.to_s
        c = Class.new(EnumString) do
          values.each do |v|
            const_name = v.upcase.gsub(/[^a-z0-9_]/i, '_').gsub(/_+/, '_')
            const_name = "V" + const_name if const_name =~ /^[0-9_]/ || const_name.blank?
            const_set(const_name, self.new(v)) unless const_defined?(const_name)

            method_name = "is_#{v.underscore}?"
            define_method(method_name) { self == v } unless self.respond_to?(method_name)
          end
        end
        c.with_values(*values)
        c.set_name(options[:name]) if options[:name]
        c
      end

      def inspect
        name.blank? ? "#<EnumString #{(values || []) * ' '}>" : name
      end
      alias_method :to_s, :inspect

      def set_name(name)
        @name = name
      end

      def name
        @name || super
      end

    end

    COLUMN_TYPE = :string

    def initialize(value)
      super(self.class.detranslated_values.nil? ? value: (self.class.detranslated_values[value.to_s] || value))
    end

    def validate
      "must be one of #{self.class.values.map{|v| v.blank? ? '\'\'' : v} * ', '}" unless self.in?(self.class.values)
    end

    def to_html(xmldoctype = true)
      self.class.translated_values[self]
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
