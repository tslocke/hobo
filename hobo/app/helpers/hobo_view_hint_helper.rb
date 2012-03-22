module HoboViewHintHelper
  extend HoboHelperBase
  protected
    # --- ViewHint Helpers --- #

    def this_field_name
      this_parent.class.try.human_attribute_name(this_field) || this_field
    end

    def this_field_help
      this_parent.class.try.attribute_help(this_field.to_sym) || ""
    end
end
