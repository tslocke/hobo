require 'rubygems'
require 'active_record'
ActiveRecord::ActiveRecordError # hack for https://rails.lighthouseapp.com/projects/8994/tickets/2577-when-using-activerecordassociations-outside-of-rails-a-nameerror-is-thrown

RUBY = File.join(Config::CONFIG['bindir'], Config::CONFIG['ruby_install_name']).sub(/.*\s.*/m, '"\&"')
RUBYDOCTEST = ENV['RUBYDOCTEST'] || "#{RUBY} -S rubydoctest"

$:.unshift File.expand_path('../../hobo_support/lib', __FILE__)
$:.unshift File.expand_path('../lib', __FILE__)
require 'hobo_support'
require 'hobo_fields'

namespace "test" do
  desc "Run the doctests"
  task :doctest do |t|
    files=Dir['test/*.rdoctest'].map {|f| File.expand_path(f)}.join(' ')
    exit(1) if !system("#{RUBYDOCTEST} #{files}")
  end

  desc "Run the unit tests"
  task :unit do |t|
    Dir["test/test_*.rb"].each do |f|
      exit(1) if !system("#{RUBY} #{f}")
    end
  end
end

require 'jeweler'
Jeweler::Tasks.new do |gemspec|
  gemspec.version      = HoboFields::VERSION
  gemspec.name         = "hobo_fields"
  gemspec.email        = "tom@tomlocke.com"
  gemspec.summary      = "Rich field types and migration generator for Rails"
  gemspec.homepage     = "http://hobocentral.net/"
  gemspec.authors      = ["Tom Locke"]
  gemspec.rubyforge_project = "hobo"
  gemspec.add_dependency("rails", [">= 3.0.0"])
  gemspec.add_dependency("hobo_support", ["= #{HoboFields::VERSION}"])
  gemspec.add_development_dependency "rubydoctest"
  gemspec.add_development_dependency "jeweler"
end
Jeweler::GemcutterTasks.new
Jeweler::RubyforgeTasks.new do |rubyforge|
  rubyforge.doc_task = false
end


desc "Prepare a rails application for testing"
task :prepare_testapp, :force do |t, args|
  args.with_default(:force => false)
  path = "/tmp/hobo_fields_testapp"
  if args.force || !File.directory?(path)
    remove_entry_secure( path, true )
    sh %(rails new #{path})
    working_dir = pwd
    chdir path
    if ENV["HOBO_DEV_ROOT"]
      dev_root = File.expand_path ENV["HOBO_DEV_ROOT"], working_dir
      sh %(echo "gem 'hobo_support', :path => '#{dev_root}/hobo_support'" >> Gemfile)
      sh %(echo "gem 'hobo_fields', :path => '#{dev_root}/hobo_fields'" >> Gemfile)
    else
      sh %(echo "gem 'hobo_support'" >> Gemfile)
      sh %(echo "gem 'hobo_fields'" >> Gemfile)
    end
    sh %(echo "" > app/models/.gitignore) # because git reset --hard would rm the dir
    rm %(.gitignore) # we need to reset everything in a testapp
    sh %(git init && git add . && git commit -m "initial commit")
    puts %(The testapp has been created in '#{path}')
  else
    chdir path
    sh %(git add .)
    sh %(git reset --hard -q HEAD)
  end
end


desc "Run all irt tests"
task :irt_test_all do |t|
  sh %(irt #{File.expand_path('../', __FILE__)})
end

