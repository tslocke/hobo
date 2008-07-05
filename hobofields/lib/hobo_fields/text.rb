module HoboFields

  class Text < String

    HTML_ESCAPE = { '&' => '&amp;', '"' => '&quot;', '>' => '&gt;', '<' => '&lt;' }

    COLUMN_TYPE = :text

    def to_html(xmldoctype = true)
      gsub(/[&"><]/) { |special| HTML_ESCAPE[special] }.gsub("\n", "<br#{xmldoctype ? ' /' : ''}>\n")
    end

    HoboFields.register_type(:text, self)

  end

end
