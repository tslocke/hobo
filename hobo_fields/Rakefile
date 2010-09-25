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

  desc "Run the irt tests"
  task :irt do |t|
    sh %(irt #{File.expand_path('../', __FILE__)})
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
      sh %(echo "gem 'irt', :group => :console" >> Gemfile) # to make the bundler happy
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

end

