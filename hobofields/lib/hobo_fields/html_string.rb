module HoboFields
  
  class HtmlString < String
  
    COLUMN_TYPE = :text
    
    def to_html
      self
    end

    HoboFields.register_type(:html, self)

  end

end
