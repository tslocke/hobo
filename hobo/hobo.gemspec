name = File.basename( __FILE__, '.gemspec' )
version = File.read(File.expand_path('../VERSION', __FILE__)).strip
require 'date'

Gem::Specification.new do |s|

  s.authors = ['Tom Locke']
  s.email = 'tom@tomlocke.com'
  s.homepage = 'http://hobocentral.net'
  s.rubyforge_project = 'hobo'
  s.summary = 'The web app builder for Rails'
  s.description = 'The web app builder for Rails'

  s.add_runtime_dependency('rails', [">= 3.0.0"])
  s.add_runtime_dependency('will_paginate', [">= 3.0.pre"])
  s.add_runtime_dependency('hobo_support', ["= #{version}"])
  s.add_runtime_dependency('hobo_fields', ["= #{version}"])
  s.add_runtime_dependency('dryml', ["= #{version}"])

  s.add_development_dependency('rubydoctest', [">= 0"])
  s.add_development_dependency('shoulda', [">= 0"])
  s.add_development_dependency('irt', [">= 0.7.5"])

  s.executables = ["hobo"]
  s.files = `git ls-files -x #{name}/* -z`.split("\0")

  s.name = name
  s.version = version
  s.date = Date.today.to_s

  s.required_rubygems_version = ">= 1.3.6"
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]

end
