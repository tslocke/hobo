module ActionView

  class Base

    def render_file_with_dryml(template_path, *args)
      @hobo_template_path = template_path
      render_file_without_dryml(template_path, *args)
    end

    alias_method_chain :render_file, :dryml

  end

end

