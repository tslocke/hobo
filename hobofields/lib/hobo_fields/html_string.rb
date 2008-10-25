module HoboFields
  
  class HtmlString < RawHtmlString

    include SanitizeHtml
    
    def self.declared(model, name, options)
      model.before_save { |record| record[name] = sanitize(record[name]) }
    end
    
    HoboFields.register_type(:html, self)
  end

end
