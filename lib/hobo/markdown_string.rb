class Hobo::MarkdownString < String
  
  def to_html
    blank? ? "" : BlueCloth.new(self).to_html
  end

end
