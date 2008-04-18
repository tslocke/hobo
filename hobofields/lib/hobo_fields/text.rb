module HoboFields
  
  class Text < String
    
    HTML_ESCAPE = { '&' => '&amp;', '"' => '&quot;', '>' => '&gt;', '<' => '&lt;' }
    
    COLUMN_TYPE = :text
    
    def to_html
      gsub(/[&"><]/) { |special| HTML_ESCAPE[special] }.gsub("\n", "<br />\n")
    end
    
    HoboFields.register_type(:text, self)
  
  end
  
end
