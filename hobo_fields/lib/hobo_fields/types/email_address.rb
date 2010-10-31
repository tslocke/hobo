require 'active_support/core_ext/string/output_safety'

module HoboFields
  module Types
    class EmailAddress < String

      COLUMN_TYPE = :string

      def validate
        I18n.t("errors.messages.invalid") unless valid? || blank?
      end

      def valid?
        self =~ /^\s*([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\s*$/i
      end

      def to_html(xmldoctype = true)
        ERB::Util.html_escape(self).sub('@', " at ").gsub('.', ' dot ')
      end

      HoboFields.register_type(:email_address, self)

    end
  end
end

