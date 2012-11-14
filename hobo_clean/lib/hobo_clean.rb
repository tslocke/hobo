require 'hobo_rapid'
require 'hobo_jquery'

module HoboClean

  VERSION = File.read(File.expand_path('../../VERSION', __FILE__)).strip
  @@root = Pathname.new File.expand_path('../..', __FILE__)
  def self.root; @@root; end

  EDIT_LINK_BASE = "https://github.com/Hobo/hobodoc/edit/master/hobo_clean"

  require 'hobo_clean/railtie' if defined?(Rails)

  class Engine < ::Rails::Engine
  end
end
