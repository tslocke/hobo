module HoboJquery
  @@root = Pathname.new File.expand_path('../..', __FILE__)
  def self.root; @@root; end

  require 'hobo-jquery/railtie' if defined?(Rails)
end
