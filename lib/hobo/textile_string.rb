class Hobo::TextileString < String

  def to_html
    if text.blank?
      ""
    else
      textilized = RedCloth.new(self, [ :hard_breaks ])
      textilized.hard_breaks = true if textilized.respond_to?("hard_breaks=")
      textilized.to_html
    end
  end  
  
end
