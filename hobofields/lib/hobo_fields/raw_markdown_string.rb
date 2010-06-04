module HoboFields

  class RawMarkdownString < HoboFields::Text

    HoboFields.register_type(:raw_markdown, self)

    def to_html(xmldoctype = true)
      blank? ? "" : Markdown.new(self).to_html
    end

  end

end
