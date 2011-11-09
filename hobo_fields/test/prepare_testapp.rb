require 'fileutils'
TESTAPP_PATH = '/tmp/hobo_fields_testapp'
system %(rake test:prepare_testapp TESTAPP_PATH=#{TESTAPP_PATH})
system %(echo "gem 'BlueCloth'" >> #{TESTAPP_PATH}/Gemfile)
system %(echo "gem 'RedCloth'" >> #{TESTAPP_PATH}/Gemfile)
FileUtils.chdir TESTAPP_PATH
require "#{TESTAPP_PATH}/config/environment"
require 'rails/generators'
Rails::Generators.configure!
