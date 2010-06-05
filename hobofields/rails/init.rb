module ::HoboFields
  class << self
    attr_accessor :rails_initializer
  end
end
::HoboFields.rails_initializer = initializer

require File.dirname(__FILE__) + "/../lib/hobofields"
HoboFields.enable
