gem 'hobosupport', "= 0.1"
require 'hobosupport'

module HoboFields
  
  extend self
  
  PLAIN_TYPES = { 
    :boolean       => Boolean,
    :date          => Date,
    :datetime      => Time,
    :integer       => Fixnum,
    :big_integer   => BigDecimal,
    :float         => Float,
    :string        => String
  }
  
  @field_types   = HashWithIndifferentAccess.new(PLAIN_TYPES)
  @never_wrap_types = Set.new([NilClass])

  attr_reader :field_types
  
  def to_type(type)
    if type.is_a?(Symbol)  
      field_types[type] 
    else
      # Assume it's already a type
      type
    end
  end
  
  
  def can_wrap?(val)
    !@never_wrap_types.include?(val.class)
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
  
end

# Add the fields do declaration to ActiveRecord::Base
ActiveRecord::Base.send(:include, HoboFields::FieldsDeclaration)


# Monkey patch ActiveRecord so that the attribute read & write methods
# automatically wrap richly-typed fields.
module ActiveRecord::AttributeMethods::ClassMethods

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
    src = if connected? && respond_to?(:field_type) && (type_wrapper = field_type(symbol)) &&
              type_wrapper.is_a?(Class) && type_wrapper.not_in?(Hobo::Model::PLAIN_TYPES.values)
            "val = begin; #{access_code}; end; " +
              "if HoboFields.can_wrap?(val); self.class.field_type(:#{attr_name}).new(val); else; val; end"
          else
            access_code
          end
    
    evaluate_attribute_method(attr_name, 
                              "def #{symbol}; @attributes_cache['#{attr_name}'] ||= begin; #{src}; end; end")
  end
  
  def define_write_method(attr_name)
    src = if connected? && respond_to?(:field_type) && (type_wrapper = field_type(attr_name)) &&
              type_wrapper.is_a?(Class) && type_wrapper.not_in?(Hobo::Model::PLAIN_TYPES.values)
            "wrapper_type = self.class.field_type(:#{attr_name}); " +
              "if !val.is_a?(wrapper_type) && HoboFields.can_wrap?(val); wrapper_type.new(val); else; val; end"
          else
            "val"
          end
    evaluate_attribute_method(attr_name, "def #{attr_name}=(val); " + 
                              "write_attribute('#{attr_name}', #{src});end", "#{attr_name}=")
    
  end

end
