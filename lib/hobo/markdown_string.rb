class Hobo::MarkdownString < String
  
  def to_html
    self.blank? ? "" : BlueCloth.new(self).to_html
  end

end
