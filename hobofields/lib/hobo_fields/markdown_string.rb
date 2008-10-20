module HoboFields

  class MarkdownString < HoboFields::Text

    include SanitizeHtml

    HoboFields.register_type(:markdown, self)

    def to_html(xmldoctype = true)
      blank? ? "" : BlueCloth.new(self).to_html
    end

  end

end
