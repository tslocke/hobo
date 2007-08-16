class Hobo::MarkdownString < String
  
  COLUMN_TYPE = :text
  
  HTML_WRAPPER = :div

  def to_html
    blank? ? "" : BlueCloth.new(self).to_html
  end

end
