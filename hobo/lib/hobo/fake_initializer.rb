# really what we want is a reference to the Initializer used in
# config/boot.rb.  But since we can't monkey patch that file, we'll
# use a fake instead.

# this is used by the rapid_summary tag with_plugins
module Hobo
  class FakeInitializer
    attr_reader :configuration
    
    def initialize(config = Rails.configuration)
      @configuration = config
    end
  end
end
