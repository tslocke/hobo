module HoboFields
  
  class HtmlString < RawHtmlString
    include SanitizeHtml
    HoboFields.register_type(:html, self)
  end

end
