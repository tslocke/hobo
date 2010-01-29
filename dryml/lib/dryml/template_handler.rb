module Dryml

  class TemplateHandler < ActionView::TemplateHandler
    
    def compile(*args)
      # Ignore - we handle compilation ourselves
    end
    
    # Pre Rails 2.2
    def render(template)
      renderer = Dryml.page_renderer_for_template(@view, template.locals.keys, template)
      this = @view.instance_variable_set("@this", @view.controller.send(:dryml_context) || template.locals[:this])
      s = renderer.render_page(this, template.locals)
      # Important to strip whitespace, or the browser hangs around for ages (FF2)
      s.strip
    end
    
    def render_for_rails22(template, view, local_assigns)
      renderer = Dryml.page_renderer_for_template(view, local_assigns.keys, template)
      this = view.controller.send(:dryml_context) || local_assigns[:this]
      @view._?.instance_variable_set("@this", this)
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

      Dryml.render_tag(@template, tag, options)
    end


    # TODO: This is namespace polution, should be called render_dryml_tag
    def render_tag(tag, attributes={}, options={})
      text = call_dryml_tag(tag, attributes)
      text && render({:text => text, :layout => false }.merge(options))
    end
    
    # DRYML fallback tags -- monkey patch this method to attempt to render a tag if there's no template
    def render_for_file_with_dryml(template, status = nil, layout = nil, locals = {})
      # in rails 2.2, "template" is actually "template_path"
      
      # if we're passed a MissingTemplateWrapper, see if there's a
      # dryml tag that will render the page
      if template.respond_to? :original_template_path
        # this is the Rails 2.3 path
        tag_name = @dryml_fallback_tag || "#{File.basename(template.original_template_path).dasherize}-page"
        
        text = call_dryml_tag(tag_name)
        if text
          return render_for_text(text, status)
        else
          template.raise_wrapped_exception
        end
      else
        begin
          result = render_for_file_without_dryml(template, status, layout, locals)
        rescue ActionView::MissingTemplate => ex
          # this is the Rails 2.2 path
          tag_name = @dryml_fallback_tag || "#{File.basename(template).dasherize}-page"
          
          text = call_dryml_tag(tag_name)
          if text
            return render_for_text(text, status)
          else
            raise ex
          end
        end
      end
    end
    alias_method_chain :render_for_file, :dryml
      
  end
end

class ActionView::Template
  
  def render_with_dryml(view, local_assigns = {})
    if handler == Dryml::TemplateHandler
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
    if view.instance_variable_defined?(:@_render_stack)
      # Rails 2.2
      stack = view.instance_variable_get(:@_render_stack)
      stack.push(self)
 
      # This is only used for TestResponse to set rendered_template
      unless is_a?(ActionView::InlineTemplate) || view.instance_variable_get(:@_first_render)
        view.instance_variable_set(:@_first_render, self)
      end

      view.send(:_evaluate_assigns_and_ivars)
      view.send(:_set_controller_content_type, mime_type) if respond_to?(:mime_type)
 
      result = Dryml::TemplateHandler.new.render_for_rails22(self, view, local_assigns)
 
      stack.pop
      result
    else
      # Rails 2.3      
      compile(local_assigns)

      view.with_template self do
        view.send(:_evaluate_assigns_and_ivars)
        view.send(:_set_controller_content_type, mime_type) if respond_to?(:mime_type)
        
        Dryml::TemplateHandler.new.render_for_rails22(self, view, local_assigns)      
      end
    end
  end
  
end

# this is only used in Rails 2.3
class MissingTemplateWrapper
  attr_reader :original_template_path
  
  def initialize(exception, path)
    @exception = exception
    @original_template_path = path
  end

  def method_missing(*args)
    raise @exception
  end

  def render
    raise @exception
  end
end
  
    
module ActionView
  class PathSet < Array
    # this is only used by Rails 2.3
    def find_template_with_dryml(original_template_path, format = nil, html_fallback = true)
      begin
        find_template_without_dryml(original_template_path, format, html_fallback)
      rescue ActionView::MissingTemplate => ex
        # instead of throwing the exception right away, hand back a
        # time bomb instead.  It'll blow if mishandled...
        return MissingTemplateWrapper.new(ex, original_template_path)
      end
    end

    if method_defined? "find_template"
      # only rails 2.3 has this function
      alias_method_chain :find_template, :dryml
    end
  end
end
        
