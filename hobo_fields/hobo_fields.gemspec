name = File.basename( __FILE__, '.gemspec' )
version = File.read(File.expand_path('../VERSION', __FILE__)).strip
require 'date'

Gem::Specification.new do |s|

  s.authors = ['Tom Locke']
  s.email = 'tom@tomlocke.com'
  s.homepage = 'http://hobocentral.net'
  s.rubyforge_project = 'hobo'
  s.summary = 'Rich field types and migration generator for Rails'
  s.description = 'Rich field types and migration generator for Rails'

  s.add_runtime_dependency('hobo_support', ["= #{version}"])
  s.add_development_dependency('rubydoctest', [">= 0"])
  s.add_development_dependency('RedCloth', [">= 0"]) # for testing rich types
  s.add_development_dependency('bluecloth', [">= 0"])  # for testing rich types

  s.executables = ["hobofields"]
  s.files = `git ls-files -x #{name}/* -z`.split("\0")

  s.name = name
  s.version = version
  s.date = Date.today.to_s

  s.required_rubygems_version = ">= 1.3.6"
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]

end

