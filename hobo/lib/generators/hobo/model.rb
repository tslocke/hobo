require 'generators/hobo_support/model'
module Generators
  module Hobo
    Model = classy_module do
      include Generators::HoboSupport::Model

      def generate_hint_file
        invoke 'hobo:hints', [name]
      end

    end
  end
end
