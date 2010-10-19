require 'fileutils'
system %(rake test:prepare_testapp)
TESTAPP_PATH = '/tmp/hobo_fields_testapp'
FileUtils.chdir TESTAPP_PATH
require 'config/environment'
require 'rails/generators'
Rails::Generators.configure!

