module Hobo
  module ViewHintsValidationsInterceptor
    def human_attribute_name(attribute_key_name, opt={})
      view_hints_field_names = self.view_hints.field_names
      attribute_key_name!="" && view_hints_field_names.include?(attribute_key_name.to_sym) ?
      view_hints_field_names[attribute_key_name.to_sym] : super
    end
  end
end
