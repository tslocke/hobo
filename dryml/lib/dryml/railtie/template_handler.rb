module Dryml
  class Railtie
    class TemplateHandler < ActionView::Template::Handler

      self.default_format = Mime::HTML

      def self.call(template)
        "Dryml.call_render(self, local_assigns, '#{template.identifier}')"
      end

    end
  end
end


