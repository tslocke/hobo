ActiveRecord::Base.class_eval do
  def read_attribute_with_hobo(attr_name)
    name = attr_name.to_s
    if self.class.can_wrap_with_hobo_type?(name)
      attr_name = attr_name.to_sym
      val = read_attribute_without_hobo(name)
      wrapper_type = self.class.attr_type(attr_name)
      if HoboFields.can_wrap?(wrapper_type, val)
        wrapper_type.new(val)
      else
        val
      end
    else
      read_attribute_without_hobo(name)
    end
  end
  alias_method_chain :read_attribute, :hobo

  class << self

    def can_wrap_with_hobo_type?(attr_name)
      if connected?
        type_wrapper = try.attr_type(attr_name)
        type_wrapper.is_a?(Class) && type_wrapper.not_in?(HoboFields::PLAIN_TYPES.values)
      else
        false
      end
    end

    def define_method_attribute=(attr_name)
      if can_wrap_with_hobo_type?(attr_name)
        src = "begin; wrapper_type = self.class.attr_type(:#{attr_name}); " +
          "if !new_value.is_a?(wrapper_type) && HoboFields.can_wrap?(wrapper_type, new_value); wrapper_type.new(new_value); else; new_value; end; end"
        generated_attribute_methods.module_eval("def #{attr_name}=(new_value); write_attribute('#{attr_name}', #{src}); end", __FILE__, __LINE__)
      else
        super
      end
    end

  end
end
