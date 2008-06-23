require File.dirname(__FILE__) + "/lib/hobo"

# 'orrible 'ack so that generators are found in symlinked plugins
if caller.grep %r(script/generate:\d+$)
  require "rails_generator"
  Rails.configuration.plugin_paths.each do |path|
    relative_path = Pathname.new(File.expand_path(path)).relative_path_from(Pathname.new(::RAILS_ROOT))
    sources = Rails::Generator::Base.sources
    sources << Rails::Generator::PathSource.new(:"plugins (#{relative_path})", "#{path}/*/**/{,rails_}generators")
  end
end