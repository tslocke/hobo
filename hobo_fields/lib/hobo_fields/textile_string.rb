require 'redcloth'

module HoboFields

  class TextileString < HoboFields::Text

    include SanitizeHtml

    def to_html(xmldoctype = true)
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
