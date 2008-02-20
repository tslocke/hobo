module HoboFields
  
  class Text < String
    
    include ERB::Util
    
    COLUMN_TYPE = :text
    
    def to_html
      html_escape(self)
    end
    
  end
  
  HoboFields.register_type(:text, self)
  
end
