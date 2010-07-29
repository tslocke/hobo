module HoboFields

  class MarkdownString < RawMarkdownString
    include SanitizeHtml

    HoboFields.register_type(:markdown, self)
    
    def to_html(xmldoctype = true)
      blank? ? "" : HoboFields::SanitizeHtml.sanitize(Markdown.new(self).to_html)
    end

  end

end
