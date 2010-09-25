require 'fileutils'
system %(rake test:prepare_testapp)
FileUtils.chdir '/tmp/hobo_fields_testapp'
require 'config/environment'
require 'rails/generators'
Rails::Generators.configure!

