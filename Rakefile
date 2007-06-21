require 'rake'
require 'rake/rdoctask'
require 'rake/testtask'

desc 'Default: run unit tests.'
task :default => :test

desc 'Generate documentation for the Hobo plugin.'
Rake::RDocTask.new(:rdoc) do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title    = 'Hobo'
  rdoc.options << '--line-numbers' << '--inline-source'
  rdoc.rdoc_files.include('README')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

desc 'Test the hobo plugin.'
Rake::TestTask.new(:test) do |t|
  raise "You should freeze edge rails in test/rails_root/vendor/rails before running the tests" unless
    File.exists?("test/rails_root/vendor/rails")
 
  t.libs << 'lib'
  t.pattern = 'test/unit/**/*_test.rb' # Update this line
  t.verbose = true
end
