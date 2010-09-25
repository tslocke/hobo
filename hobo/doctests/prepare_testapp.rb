require 'fileutils'
system %(rake test:prepare_testapp)
FileUtils.chdir '/tmp/hobo_testapp'
require 'config/environment'
require 'rails/generators'
Rails::Generators.configure!

