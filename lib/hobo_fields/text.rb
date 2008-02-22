module HoboFields
  
  class Text < String
    
    HTML_ESCAPE = { '&' => '&amp;', '"' => '&quot;', '>' => '&gt;', '<' => '&lt;' }
    
    COLUMN_TYPE = :text
    
    def to_html
      s.to_s.gsub(/[&"><]/) { |special| HTML_ESCAPE[special] }
    end
    
  end
  
  HoboFields.register_type(:text, self)
  
end
