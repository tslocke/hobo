require 'rubygems'
require 'hoe'

$: << "./lib" 

require 'hobosupport'

Hoe.new('hobosupport', HoboSupport::VERSION) do |p|
  p.rubyforge_name = 'hobo'
  p.author = 'Tom Locke'
  p.email = 'tom@tomlocke.com'
  p.url = "http://hobocentral.net/hobo-support"
  p.summary = 'Core Ruby extensions from the Hobo project'
  p.description = p.paragraphs_of('README.txt', 2..5).join("\n\n")
  p.changes = p.paragraphs_of('History.txt', 0..1).join("\n\n")
end

