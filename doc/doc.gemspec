# this is a gem only so it can get included into the cookbook.   You
# don't actually release or install it.

name = File.basename( __FILE__, '.gemspec' )
version = '0.0.1'
require 'date'

Gem::Specification.new do |s|

  s.authors = ['Bryan Larsen']
  s.email = 'bryan@larsen.st'
  s.homepage = 'http://hobocentral.net'
  s.rubyforge_project = 'hobo'
  s.summary = 'The Hobo manual'
  s.description = 'The Hobo manual'

  s.files = `git ls-files -x #{name}/* -z`.split("\0")

  s.name = name
  s.version = version
  s.date = Date.today.to_s

  s.rdoc_options = ["--charset=UTF-8"]

end
