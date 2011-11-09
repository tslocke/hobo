module Dryml
  class Railtie
    class TemplateHandler

      def self.call(template)
        "Dryml.call_render(self, local_assigns, '#{template.identifier}')"
      end

    end
  end
end


