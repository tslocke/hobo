require 'active_support/core_ext/string/output_safety'
module HoboFields
  module Types
    class Text < String

      COLUMN_TYPE = :text

      def to_html(xmldoctype = true)
        ERB::Util.html_escape(self).gsub("\n", "<br#{xmldoctype ? ' /' : ''}>\n")
      end

      HoboFields.register_type(:text, self)

    end
  end
end
