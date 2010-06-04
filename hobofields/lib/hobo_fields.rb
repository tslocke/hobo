require 'hobosupport'
require 'active_support/dependencies'

ActiveSupport::Dependencies.load_paths |= [ File.dirname(__FILE__) ]

module Hobo
  # Empty class to represent the boolean type.
  class Boolean; end
end

module HoboFields

  VERSION = "1.1.0.pre0"

  extend self

  PLAIN_TYPES = {
    :boolean       => Hobo::Boolean,
    :date          => Date,
    :datetime      => (defined?(ActiveSupport::TimeWithZone) ? ActiveSupport::TimeWithZone : Time),
    :time          => Time,
    :integer       => Integer,
    :decimal       => BigDecimal,
    :float         => Float,
    :string        => String
  }

  ALIAS_TYPES = {
    Fixnum => "integer",
    Bignum => "integer"
  }

  # Provide a lookup for these rather than loading them all preemptively
  
  STANDARD_TYPES = {
    :raw_html      => "RawHtmlString",
    :html          => "HtmlString",
    :raw_markdown  => "RawMarkdownString",
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
    if type.is_one_of?(Symbol, String)
      type = type.to_sym
      field_types[type] || standard_class(type)
    else
      type # assume it's already a class
    end
  end


  def to_name(type)
    field_types.key(type) || ALIAS_TYPES[type]
  end


  def can_wrap?(type, val)
    col_type = type::COLUMN_TYPE
    return false if val.blank? && (col_type == :integer || col_type == :float || col_type == :decimal)
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
    require "hobo_fields/attribute_methods"
    require "hobo_fields/enum_string"
    require "hobo_fields/fields_declaration"

    # Add the fields do declaration to ActiveRecord::Base
    ActiveRecord::Base.send(:include, HoboFields::FieldsDeclaration)

    # automatically load other rich types from app/rich_types/*.rb
    # don't assume we're in a Rails app
    if defined?(::Rails)
      plugins = Rails.configuration.plugin_loader.new(HoboFields.rails_initializer).plugins
      ([::Rails.root] + plugins.map(&:directory)).each do |dir|
        ActiveSupport::Dependencies.load_paths << File.join(dir, 'app', 'rich_types')
        Dir[File.join(dir, 'app', 'rich_types', '*.rb')].each do |f|
          # TODO: should we complain if field_types doesn't get a new value? Might be useful to warn people if they're missing a register_type
          require_dependency f
        end
      end

    end
    
    # Override ActiveRecord's default methods so that the attribute read & write methods
    # automatically wrap richly-typed fields.
    ActiveRecord::Base.send :include, AttributeMethods

  end

end
