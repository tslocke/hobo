require 'rails/generators/active_record'

module Hobo
  class ModelGenerator < ActiveRecord::Generators::Base
    source_root File.expand_path('../templates', __FILE__)

    include Generators::Hobo::Model

  end
end
