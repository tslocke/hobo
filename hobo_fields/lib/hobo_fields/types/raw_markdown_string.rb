module HoboFields
  module Types
    class RawMarkdownString < HoboFields::Types::Text

      HoboFields.register_type(:raw_markdown, self)

      def to_html(xmldoctype = true)
        blank? ? "" : Markdown.new(self).to_html.html_safe
      end

    end
  end
end
