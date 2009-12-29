module ::Hobo
  class << self
    attr_accessor :rails_initializer
  end
end
::Hobo.rails_initializer = initializer

require File.dirname(__FILE__) + "/../lib/hobo"
require 'rails_generator'
Hobo.enable
