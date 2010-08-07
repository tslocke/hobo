require 'hobo_support/model_generator_module'
module Hobo
  Generators::ModelModule = classy_module do
    include HoboSupport::ModelGeneratorModule

    check_class_collision :suffix => 'Hints'

    def generate_hint_file
      template 'hints.rb.erb', File.join("app/viewhints", "#{file_path}_hints.rb")
    end

  end
end
