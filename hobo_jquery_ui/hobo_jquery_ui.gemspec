name = File.basename( __FILE__, '.gemspec' )
version = File.read(File.expand_path('../VERSION', __FILE__)).strip
require 'date'

spec = Gem::Specification.new do |s|
  s.name = "hobo_jquery_ui"
  s.summary = "JQuery UI support for Hobo"
  s.description = "JQuery UI support for Hobo"
  s.authors = ["Bryan Larsen"]
  s.email = "bryan@larsen.st"
  s.files = `git ls-files -x #{name}/* -z`.split("\0")
  s.homepage = 'http://hobocentral.net'
  s.version = version
  s.date = Date.today.to_s

  s.required_rubygems_version = ">= 1.3.6"
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib", "vendor", "taglibs"]

  s.add_runtime_dependency("jquery-ui-themes", ["~> 0.0.4"])
  s.add_runtime_dependency('hobo', ["= #{version}"])
  s.add_runtime_dependency('hobo_jquery', ["= #{version}"])

end
