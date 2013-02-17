name = File.basename( __FILE__, '.gemspec' )
version = File.read(File.expand_path('../VERSION', __FILE__)).strip
require 'date'

Gem::Specification.new do |s|

  s.authors = ['Tom Locke']
  s.email = 'tom@tomlocke.com'
  s.homepage = 'http://hobocentral.net'
  s.rubyforge_project = 'hobo'
  s.summary = "The Don't Repeat Yourself Markup Language"
  s.description = "The Don't Repeat Yourself Markup Language"

  s.add_runtime_dependency('actionpack', [">= 3.2.0"])
  s.add_runtime_dependency('hobo_support', ["= #{version}"])
  s.add_development_dependency('rubydoctest', [">= 1.1.3"])
  s.add_development_dependency('cucumber', '~> 1.1.0')
  s.add_development_dependency('aruba', '~> 0.4.6')

  s.files = `git ls-files -x #{name}/* -z`.split("\0")

  s.name = File.basename( __FILE__, '.gemspec' )
  s.version = version
  s.date = Date.today.to_s

  s.required_rubygems_version = ">= 1.3.6"
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]

  s.extensions = 'ext/mkrf_conf.rb'
end
