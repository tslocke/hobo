require 'generators/hobo_support/model'
module Generators
  module Hobo
    Model = classy_module do
      include Generators::HoboSupport::Model

      check_class_collision :suffix => 'Hints'

      def generate_hint_file
        template 'hints.rb.erb', File.join("app/viewhints", "#{file_path}_hints.rb")
      end

    end
  end
end
