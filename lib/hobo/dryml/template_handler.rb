module Hobo::Dryml

  class TemplateHandler

    def initialize(view)
      @view = view
    end

    def render(src, local_assigns)
      renderer = Hobo::Dryml.page_renderer(@view, local_assigns.keys)
      this = @view.instance_variable_set("@this", @view.controller.send(:dryml_context) || local_assigns[:this])
      s = renderer.render_page(this, local_assigns) 

      # Important to strip whitespace, or the browser hangs around for ages (FF2)
      s = s.strip
      
      # TODO: Temporary hack to get the dryml metadata comments in the right place
      if RAILS_ENV == "development"
        s.gsub(/^(.*?)(<!DOCTYPE.*?>).*?(<html.*?>)/m, "\\2\\3\\1") 
      else
        s
      end
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
      add_variables_to_assigns
      
      # TODO: Figure out what this bit is all about :-)
      if options[:with]
        @this = options[:with] unless options[:field]
      else
        options[:with] = dryml_context
      end
      
      Hobo::Dryml.render_tag(@template, tag, options)
    end
    
    
    # TODO: This is namespace polution, should be called render_dryml_tag
    def render_tag(tag, options={}, render_options={})
      text = call_dryml_tag(tag, options)
      text && render({:text => text, :layout => false }.merge(render_options))
    end

    def render_for_file_with_dryml(template_path, *args)
      if template_path !~ /^([a-z]:)?\// &&                    # not an absolute path (e.g. an exception ERB template)
          !template_exists?(template_path) &&                  # no template available in app/views
          tag_name = @dryml_fallback_tag || "#{File.basename(template_path).dasherize}-page"

          # The template was missing, try to use a DRYML <page> tag instead
          render_tag(tag_name) or raise ActionController::MissingTemplate, "Missing template #{template_path}.html.erb in view path #{RAILS_ROOT}/app/views"
      else
        render_for_file_without_dryml(template_path, *args)
      end
    end
    alias_method_chain :render_for_file, :dryml
    
  end
end
