module HoboFields
  
  class RawHtmlString < HoboFields::Text

    def to_html(xmldoctype = true)
      self
    end

    HoboFields.register_type(:raw_html, self)

  end
  
end