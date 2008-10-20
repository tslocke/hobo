module HoboFields

  class HtmlString < HoboFields::Text

    include SanitizeHtml

    def to_html(xmldoctype = true)
      self
    end

    HoboFields.register_type(:html, self)

  end

end
