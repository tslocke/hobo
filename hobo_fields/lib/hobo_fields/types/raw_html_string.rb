module HoboFields
  module Types
    class RawHtmlString < HoboFields::Types::Text

      def to_html(xmldoctype = true)
        self.html_safe
      end

      HoboFields.register_type(:raw_html, self)

    end
  end
end
