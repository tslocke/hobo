module Hobo::Dryml

  class TemplateHandler < ActionView::TemplateHandler
    
    def compile(*args)
      # Ignore - we handle compilation ourselves
    end
    
    # Pre Rails 2.2
    def render(template)
      renderer = Hobo::Dryml.page_renderer_for_template(@view, template.locals.keys, template)
      this = @view.instance_variable_set("@this", @view.controller.send(:dryml_context) || template.locals[:this])
      s = renderer.render_page(this, template.locals)
      # Important to strip whitespace, or the browser hangs around for ages (FF2)
      s.strip
    end
    
    def render_for_rails22(template, view, local_assigns)
      renderer = Hobo::Dryml.page_renderer_for_template(view, local_assigns.keys, template)
      this = @view.instance_variable_set("@this", view.controller.send(:dryml_context) || local_assigns[:this])
      s = renderer.render_page(this, local_assigns)

      # Important to strip whitespace, or the browser hangs around for ages (FF2)
      s.strip
    end

  end

end

module ActionController

  class Base

    def dryml_context
      @this
    end

    def dryml_fallback_tag(tag_name)
      @dryml_fallback_tag = tag_name
    end


    def call_dryml_tag(tag, options={})
      @template.send(:_evaluate_assigns_and_ivars)

      # TODO: Figure out what this bit is all about :-)
      if options[:with]
        @this = options[:with] unless options[:field]
      else
        options[:with] = dryml_context
      end

      Hobo::Dryml.render_tag(@template, tag, options)
    end


    # TODO: This is namespace polution, should be called render_dryml_tag
    def render_tag(tag, attributes={}, options={})
      text = call_dryml_tag(tag, attributes)
      text && render({:text => text, :layout => false }.merge(options))
    end


    # DRYML fallback tags -- monkey patch this method to attempt to render a tag if there's no template
    def render_for_file_with_dryml(template_path, status = nil, layout = nil, locals = {})
      render_for_file_without_dryml(template_path, status, layout, locals)
    rescue ActionView::MissingTemplate => ex
      # Try to use a DRYML <page> tag instead
      tag_name = @dryml_fallback_tag || "#{File.basename(template_path).dasherize}-page"

      text = call_dryml_tag(tag_name)
      if text
        render_for_text text, status 
      else
        raise ex
      end
    end
    alias_method_chain :render_for_file, :dryml

  end
end

class ActionView::Template
  
  def render_with_dryml(view, local_assigns = {})
    if handler == Hobo::Dryml::TemplateHandler
      render_dryml(view, local_assigns)
    else
      render_without_dryml(view, local_assigns)
    end
  end
  alias_method_chain :render, :dryml
  
  # We've had to copy a bunch of logic from Renderable#render, because we need to prevent Rails
  # from trying to compile our template. DRYML templates are each compiled as a class, not just a method,
  # so the support for compiling templates that Rails provides is innadequate.
  def render_dryml(view, local_assigns = {})
    stack = view.instance_variable_get(:@_render_stack)
    stack.push(self)

    # This is only used for TestResponse to set rendered_template
    unless is_a?(ActionView::InlineTemplate) || view.instance_variable_get(:@_first_render)
      view.instance_variable_set(:@_first_render, self)
    end

    view.send(:_evaluate_assigns_and_ivars)
    view.send(:_set_controller_content_type, mime_type) if respond_to?(:mime_type)

    result = Hobo::Dryml::TemplateHandler.new.render_for_rails22(self, view, local_assigns)

    stack.pop
    result
  end
  
end  
    