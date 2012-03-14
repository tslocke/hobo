module HoboJquery
  @@root = Pathname.new File.expand_path('../..', __FILE__)
  def self.root; @@root; end

  EDIT_LINK_BASE = "https://github.com/tablatom/hobo_tree_table/edit/master/hobo_jquery"

  require 'hobo_jquery/railtie' if defined?(Rails)

  class Engine < ::Rails::Engine
  end
end
