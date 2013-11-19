ActiveSupport::Dependencies.autoload_paths |= [File.dirname(__FILE__)]
ActiveSupport::Dependencies.autoload_once_paths |= [File.dirname(__FILE__)]

module HoboRapid

  VERSION = File.read(File.expand_path('../../VERSION', __FILE__)).strip
  @@root = Pathname.new File.expand_path('../..', __FILE__)
  def self.root; @@root; end

  EDIT_LINK_BASE = "https://github.com/Hobo/hobodoc/edit/master/hobo_rapid"

  require 'hobo_rapid/previous_uri_filter'
  require 'hobo_rapid/railtie' if defined?(Rails)

  class Engine < ::Rails::Engine
  end
end
