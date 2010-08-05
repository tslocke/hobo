require 'rails/generators/active_record'
require 'hobo_support/model_generator_helper'

module Hobo
  class ModelGenerator < ActiveRecord::Generators::Base
    source_root File.expand_path('../templates', __FILE__)

    include HoboSupport::ModelGeneratorHelper

    check_class_collision :suffix => 'Hints'

    def generate_hint_file
      template 'hints.rb.erb', File.join("app/viewhints", "#{file_path}_hints.rb")
    end

  end
end
