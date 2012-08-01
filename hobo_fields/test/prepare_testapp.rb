require 'fileutils'
require 'tmpdir'

TESTAPP_PATH = ENV['TESTAPP_PATH'] || File.join(Dir.tmpdir, 'hobo_fields_testapp')
system %(rake test:prepare_testapp TESTAPP_PATH=#{TESTAPP_PATH})
system %(echo "gem 'bluecloth'" >> #{TESTAPP_PATH}/Gemfile)
system %(echo "gem 'RedCloth'" >> #{TESTAPP_PATH}/Gemfile)
FileUtils.chdir TESTAPP_PATH
require "#{TESTAPP_PATH}/config/environment"
require 'rails/generators'
Rails::Generators.configure!(Rails.application.config.generators)
