require 'rake'
require 'rake/rdoctask'
require 'rake/testtask'

desc "Default Task"
task :default => [ :test ]


# --- Testing --- #

desc "Run all unit tests"
Rake::TestTask.new(:test) { |t|
  t.libs << "test"
  t.test_files=Dir.glob( "test/**/*_test.rb" ).sort
  t.verbose = true
}


# --- RDoc --- #

desc 'Generate documentation for the Hobo plugin.'
Rake::RDocTask.new(:rdoc) do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title    = 'Hobo'
  rdoc.options << '--line-numbers' << '--inline-source'
  rdoc.rdoc_files.include('README')
  rdoc.rdoc_files.include('lib/**/*.rb')
end


# --- Packaging and Rubyforge --- #

require 'echoe'

Echoe.new('hobo') do |p|
  p.author  = "Tom Locke"
  p.email   = "tom@tomlocke.com"
  p.summary = "The web app builder for Rails"
  p.url     = "http://hobocentral.net/"
  p.project = "hobo"

  p.changelog = "CHANGES.txt"
  p.version   = "0.8.5"

  p.dependencies = [
    'hobosupport =0.8.5',
    'hobofields =0.8.5',
    'rails >=2.2.2',
    'mislav-will_paginate >=2.2.1']
    
  p.development_dependencies = []
end



