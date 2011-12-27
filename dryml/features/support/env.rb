lib = File.expand_path('../../../lib', __FILE__)
$:.unshift lib unless $:.include?(lib)

require 'bundler'
Bundler.setup
require 'aruba/cucumber'

require 'active_support'
require 'action_view'
require 'action_controller'

require 'dryml'
require 'dryml/railtie/template_handler'

def aruba_path(file_or_dir)
  File.expand_path("../../../tmp/aruba/#{file_or_dir}", __FILE__)
end

After do
  # muck out the caches
  Dryml::Taglib.clear_cache
  Dryml::Template.clear_build_cache
  Dryml.clear_cache
end

# stub this
module Hobo
  def self.root
    'no_such_path'
  end
end

