class Hobo::MarkdownString < String
  
  COLUMN_TYPE = :text
  
  def to_html
    blank? ? "" : BlueCloth.new(self).to_html
  end

end
