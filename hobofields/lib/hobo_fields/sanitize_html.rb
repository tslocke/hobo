module HoboFields

  module SanitizeHtml

    PERMITTED_TAGS       = %w(a abbr acronym address b bdo big blockquote br caption center cite code colgroup dd del dfn dir
                              div dl dt em fieldset font h1 h2 h3 h4 h5 h6 i img ins kbd label legend li map menu ol optgroup
                              option p pre q s samp select small span strike strong sub sup tbody td textarea tfoot
                              th thead tr tt u ul var)

    PERMITTED_ATTRIBUTES = %w(href title class style align name src label target)

    class Helper; include ActionView::Helpers::SanitizeHelper; extend ActionView::Helpers::SanitizeHelper::ClassMethods; end
        
    def self.sanitize(s)
      Helper.new.sanitize(s, :tags => PERMITTED_TAGS, :attributes => PERMITTED_ATTRIBUTES)
    end

  end

end