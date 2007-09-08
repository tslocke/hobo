module ActionView

  class Base

    alias_method :render_file_without_hobo, :render_file
    def render_file(template_path, *args)
      @hobo_template_path = template_path
      render_file_without_hobo(template_path, *args)
    end

  end

end

