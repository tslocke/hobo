RUBY = File.join(Config::CONFIG['bindir'], Config::CONFIG['ruby_install_name']).sub(/.*\s.*/m, '"\&"')
RUBYDOCTEST = ENV['RUBYDOCTEST'] || "#{RUBY} `which rubydoctest`"

desc "Run tests and doctests for all components."
task :test_all do |t|
  puts "These are a small fraction of the tests available for Hobo.   Run the rest from http://github.com/bryanlarsen/hobo-test-environment"
  system("cd dryml ; #{RUBY} -S rake test") &&
    system("cd hobo_fields ; #{RUBY} -S rake test:doctest") &&
    system("cd hobo_fields ; #{RUBY} -S rake test:unit") &&
    system("cd hobo_support ; #{RUBY} -S rake test:doctest") &&
    system("cd hobo ; #{RUBY} -S rake test:doctest") &&
    system("cd hobo ; #{RUBY} -S rake test")
  exit($?.exitstatus)
end

require 'yard'
YARD::Rake::YardocTask.new do |t|
  t.files = ['*/lib/**/*.rb', '-', 'hobo/README', 'hobo/CHANGES.txt', 'hobo/LICENSE.txt', 'dryml/README', 'dryml/CHANGES.txt']
end

TESTAPP_PATH = '/tmp/testapp'
ROOT_PATH = File.expand_path('../', __FILE__)

require 'fileutils'
desc "Prepare a rails-hobo application for testing"
task :prepare_testapp do |t|
  remove_entry_secure( TESTAPP_PATH, true )
  sh %(hobo new #{TESTAPP_PATH} --skip-wizard)
  chdir TESTAPP_PATH
  sh %(echo "gem 'irt', '>= 0.7.5', :group => :console" >> Gemfile)
  sh %(echo "" > app/models/.gitignore) # because git reset --hard would rm the dir
  sh %(git init && git add . && git commit -m "initial commit")
  puts %(The appdir has been created in '#{TESTAPP_PATH}')
end


desc "Run all irt tests"
task :irt_test_all => [:prepare_testapp] do |t|
  sh %(irt #{ROOT_PATH})
end
