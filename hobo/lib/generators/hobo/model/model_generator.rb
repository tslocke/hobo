require 'rails/generators/active_record'
require 'generators/hobo_support/model'

module Hobo
  class ModelGenerator < ActiveRecord::Generators::Base
    source_root File.expand_path('../templates', __FILE__)

    include Generators::HoboSupport::Model

  end
end
