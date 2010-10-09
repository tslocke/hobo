module Dryml
  class Railtie
    class PageTagResolver < ActionView::Resolver

      def initialize(controller)
        @controller = controller
        super()
      end

      def find_templates(name, prefix, partial, details)
        tag_name = @dryml_fallback_tag || name.dasherize + '-page'
        text = @controller.call_dryml_tag(tag_name)
        return [] unless text
        [ActionView::Template.new(text, "dryml-tag:#{tag_name}", Dryml::Railtie::PageTagHandler, details)]
      end

    end
  end
end
