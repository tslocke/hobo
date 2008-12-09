require 'hobosupport'

ActiveSupport::Dependencies.load_paths |= [ File.dirname(__FILE__) ]

module Hobo
  # Empty class to represent the boolean type.
  class Boolean; end
end

module HoboFields

  VERSION = "0.8.5"

  extend self

  PLAIN_TYPES = {
    :boolean       => Hobo::Boolean,
    :date          => Date,
    :datetime      => (defined?(ActiveSupport::TimeWithZone) ? ActiveSupport::TimeWithZone : Time),
    :time          => Time,
    :integer       => Fixnum,
    :big_integer   => BigDecimal,
    :decimal       => BigDecimal,
    :float         => Float,
    :string        => String
  }

  # Provide a lookup for these rather than loading them all preemptively
  
  STANDARD_TYPES = {
    :html          => "HtmlString",
    :markdown      => "MarkdownString",
    :textile       => "TextileString",
    :password      => "PasswordString",
    :text          => "Text",
    :email_address => "EmailAddress",
    :serialized    => "SerializedObject"
  }

  @field_types   = PLAIN_TYPES.with_indifferent_access
  
  @never_wrap_types = Set.new([NilClass, Hobo::Boolean, TrueClass, FalseClass])

  attr_reader :field_types

  def to_class(type)
    if type.is_a?(Symbol, String)
      type = type.to_sym
      field_types[type] || standard_class(type)
    else
      type # assume it's already a class
    end
  end


  def to_name(type)
    field_types.index(type)
  end


  def can_wrap?(type, val)
    klass = Object.instance_method(:class).bind(val).call # Make sure we get the *real* class
    arity = type.instance_method(:initialize).arity
    (arity == 1 || arity == -1) && !@never_wrap_types.any? { |c| klass <= c }
  end


  def never_wrap(type)
    @never_wrap_types << type
  end


  def register_type(name, klass)
    field_types[name] = klass
  end


  def plain_type?(type_name)
    type_name.in?(PLAIN_TYPES)
  end


  def standard_class(name)
    class_name = STANDARD_TYPES[name]
    "HoboFields::#{class_name}".constantize if class_name
  end

  def enable
    require "hobo_fields/enum_string"
    require "hobo_fields/fields_declaration"

    # Add the fields do declaration to ActiveRecord::Base
    ActiveRecord::Base.send(:include, HoboFields::FieldsDeclaration)

    # Monkey patch ActiveRecord so that the attribute read & write methods
    # automatically wrap richly-typed fields.
    ActiveRecord::AttributeMethods::ClassMethods.class_eval do

      # Define an attribute reader method.  Cope with nil column.
      def define_read_method(symbol, attr_name, column)
        cast_code = column.type_cast_code('v') if column
        access_code = cast_code ? "(v=@attributes['#{attr_name}']) && #{cast_code}" : "@attributes['#{attr_name}']"

        unless attr_name.to_s == self.primary_key.to_s
          access_code = access_code.insert(0, "missing_attribute('#{attr_name}', caller) " +
                                           "unless @attributes.has_key?('#{attr_name}'); ")
        end

        # This is the Hobo hook - add a type wrapper around the field
        # value if we have a special type defined
        src = if connected? && (type_wrapper = try.attr_type(symbol)) &&
                  type_wrapper.is_a?(Class) && type_wrapper.not_in?(HoboFields::PLAIN_TYPES.values)
                "val = begin; #{access_code}; end; wrapper_type = self.class.attr_type(:#{attr_name}); " +
                  "if HoboFields.can_wrap?(wrapper_type, val); wrapper_type.new(val); else; val; end"
              else
                access_code
              end

        evaluate_attribute_method(attr_name,
                                  "def #{symbol}; @attributes_cache['#{attr_name}'] ||= begin; #{src}; end; end")
      end

      def define_write_method(attr_name)
        src = if connected? && (type_wrapper = try.attr_type(attr_name)) &&
                  type_wrapper.is_a?(Class) && type_wrapper.not_in?(HoboFields::PLAIN_TYPES.values)
                "begin; wrapper_type = self.class.attr_type(:#{attr_name}); " +
                  "if !val.is_a?(wrapper_type) && HoboFields.can_wrap?(wrapper_type, val); wrapper_type.new(val); else; val; end; end"
              else
                "val"
              end
        evaluate_attribute_method(attr_name,
                                  "def #{attr_name}=(val); write_attribute('#{attr_name}', #{src});end", "#{attr_name}=")

      end

    end

  end

end


HoboFields.enable if defined? ActiveRecord
