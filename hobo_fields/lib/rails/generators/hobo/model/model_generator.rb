require 'rails/generators/active_record'
require 'hobo_support/model_generator_helper'

module Hobo
  class ModelGenerator < ActiveRecord::Generators::Base
    source_root File.expand_path('../templates', __FILE__)

    include HoboSupport::ModelGeneratorModule

  end
end
