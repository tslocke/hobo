module Dryml
  if ActionView.const_defined? :Resolver
    # quacks like a Rails3 ActionView::Template
    class MissingTemplate
      attr_reader :details
      
      def identifier
        "#{@prefix}/#{@name}"
      end
      
      def mime_type
        details[:mime_type]
      end
      
      def initialize(name, details, prefix, partial)
        @name = name
        @details = details
        @prefix = prefix
        @partial = partial
      end
      
      def render(view, locals, &block)
        renderer = Dryml.empty_page_renderer(view)
        renderer.render_tag("#{@name}-page", locals)
      end
      
    end
    
    class FallbackResolver < ActionView::Resolver
      def find_templates(*args)
        [Dryml::MissingTemplate.new(*args)]
      end
    end
  end
end
