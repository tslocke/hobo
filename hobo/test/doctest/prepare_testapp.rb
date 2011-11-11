require 'fileutils'
TESTAPP_PATH = '/tmp/hobo_testapp'
system %(rake test:prepare_testapp TESTAPP_PATH=#{TESTAPP_PATH})
FileUtils.chdir TESTAPP_PATH
require 'config/environment'
require 'rails/generators'
Rails::Generators.configure!

