module HoboFields
  module Types
    class LifecycleState < String

      COLUMN_TYPE = :string

      class << self
        attr_accessor :model_name
      end

      def to_html(xmldoctype = true)
        I18n.t("activerecord.attributes.#{self.class.model_name.underscore}.lifecycle.states.#{self}", :default => self).html_safe
      end
    end
  end
end
