module Hobo
  class HintsGenerator < Rails::Generators::NamedBase
    source_root File.expand_path('../templates', __FILE__)

    check_class_collision :suffix => 'Hints'

    def generate_hints
      template 'hints.rb.erb', File.join("app/viewhints", "#{file_path}_hints.rb")
    end

  end
end
