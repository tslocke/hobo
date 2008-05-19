module HoboFields
  
  class HtmlString < HoboFields::Text
  
    def to_html
      self
    end

    HoboFields.register_type(:html, self)

  end

end
