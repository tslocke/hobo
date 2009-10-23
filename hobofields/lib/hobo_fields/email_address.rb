module HoboFields

  class EmailAddress < String

    COLUMN_TYPE = :string

    def validate
      I18n.t("activerecord.errors.messages.invalid") unless valid? || blank?
    end

    def valid?
      self =~ /^\s*([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\s*$/i
    end

    def to_html(xmldoctype = true)
      self.sub('@', " at ").gsub('.', ' dot ')
    end

    HoboFields.register_type(:email_address, self)

  end

end

