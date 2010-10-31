module HoboFields
  module Types
    class PasswordString < String

      COLUMN_TYPE = :string

      HoboFields.register_type(:password, self)

      def to_html(xmldoctype = true)
        I18n.t("hobo.password_hidden", :default => "[password hidden]").html_safe
      end

    end
  end
end
