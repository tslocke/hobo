module HoboFields
  
  class MarkdownString < String
  
    COLUMN_TYPE = :text

    HoboFields.register_type(:markdown, self)

    def to_html
      blank? ? "" : BlueCloth.new(self).to_html
    end

  end

end
