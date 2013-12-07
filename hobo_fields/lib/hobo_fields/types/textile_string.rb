module HoboFields
  module Types
    class TextileString < HoboFields::Types::Text

      include SanitizeHtml

      def to_html(xmldoctype = true)
        require 'redcloth'

        if blank?
          ""
        else
          textilized = RedCloth.new(self, [ :hard_breaks ])
          textilized.hard_breaks = true if textilized.respond_to?("hard_breaks=")
          HoboFields::SanitizeHtml.sanitize(textilized.to_html)
        end
      end

      HoboFields.register_type(:textile, self)
    end
  end
end
