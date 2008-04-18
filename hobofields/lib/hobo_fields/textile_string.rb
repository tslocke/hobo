require 'redcloth'

module HoboFields
  
  class TextileString < HoboFields::Text

    def to_html
      if blank?
        ""
      else
        textilized = RedCloth.new(self, [ :hard_breaks ])
        textilized.hard_breaks = true if textilized.respond_to?("hard_breaks=")
        textilized.to_html
      end
    end  

    HoboFields.register_type(:textile, self)
  end

end

class RedCloth
  # Patch for RedCloth.  Fixed in RedCloth r128 but _why hasn't released it yet.
  # http://code.whytheluckystiff.net/redcloth/changeset/128
  def hard_break( text ) 
    text.gsub!( /(.)\n(?!\n|\Z| *([#*=]+(\s|$)|[{|]))/, "\\1<br />" ) if hard_breaks && RedCloth::VERSION == "3.0.4"
  end 
end

