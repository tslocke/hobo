require 'rake'
require 'rake/rdoctask'
require 'rake/testtask'

require 'activerecord'
ActiveRecord::ActiveRecordError # hack for https://rails.lighthouseapp.com/projects/8994/tickets/2577-when-using-activerecordassociations-outside-of-rails-a-nameerror-is-thrown
$:.unshift File.join(File.expand_path(File.dirname(__FILE__)), '/lib')
$:.unshift File.join(File.expand_path(File.dirname(__FILE__)), '/../hobofields/lib')
$:.unshift File.join(File.expand_path(File.dirname(__FILE__)), '/../hobosupport/lib')
require 'hobo'

desc "Default Task"
task :default => [ :test ]


# --- Testing --- #

desc "Run all unit tests"
Rake::TestTask.new(:test) { |t|
  t.libs << "test"
  t.test_files=Dir.glob( "test/**/*_test.rb" ).sort
  t.verbose = true
}

namespace "test" do
  desc "Run the doctests"
  task :doctest do |t|
    # note, tests in doctest/hobo/ are out of date
    exit(1) if !system("rubydoctest doctest/*.rdoctest")
  end
end

# --- RDoc --- #

desc 'Generate documentation for the Hobo plugin.'
Rake::RDocTask.new(:rdoc) do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title    = 'Hobo'
  rdoc.options << '--line-numbers' << '--inline-source'
  rdoc.rdoc_files.include('README')
  rdoc.rdoc_files.include('lib/**/*.rb')
end


# --- Packaging and Rubyforge & gemcutter & github--- #

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gemspec|
    gemspec.version      = Hobo::VERSION
    gemspec.name         = "hobo"
    gemspec.email        = "tom@tomlocke.com"
    gemspec.summary      = "The web app builder for Rails"
    gemspec.homepage     = "http://hobocentral.net/"
    gemspec.authors      = ["Tom Locke"]
    gemspec.rubyforge_project = "hobo"
    gemspec.files        = FileList["**"]
    gemspec.add_dependency("rails", [">= 2.2.2"])
    gemspec.add_dependency("mislav-will_paginate", [">= 2.2.1"])
    gemspec.add_dependency("hobosupport", ["= #{Hobo::VERSION}"])
    gemspec.add_dependency("hobofields", ["= #{Hobo::VERSION}"])    
  end
  Jeweler::GemcutterTasks.new
  Jeweler::RubyforgeTasks.new do |rubyforge|
    rubyforge.doc_task = "rdoc"
  end
rescue LoadError
  puts "Jeweler not available. Install it with: sudo gem install technicalpickles-jeweler -s http://gems.github.com"
end
