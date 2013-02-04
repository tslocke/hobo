module HoboFields
  module Types
    class RawMarkdownString < HoboFields::Types::Text

      @@markdown_class = case
        when defined?(RDiscount)
          RDiscount
        when defined?(Kramdown)
          Kramdown::Document
        when defined?(Maruku)
          Maruku
        else
          Markdown
        end

      HoboFields.register_type(:raw_markdown, self)

      def to_html(xmldoctype = true)
        blank? ? "" : @@markdown_class.new(self).to_html.html_safe
      end

    end
  end
end
