module Dryml
  class Railtie
    class PageTagHandler < ActionView::Template::Handler

      self.default_format = Mime::HTML

      def self.call(template)
        "ActionView::Template::Text.new(%q(#{template.source}), Mime::HTML).render"
      end

    end
  end
end
