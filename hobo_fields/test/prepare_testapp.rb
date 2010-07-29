require 'fileutils'
TEST_APP_ROOT = File.expand_path('../testapp',__FILE__)
FileUtils.rm_rf TEST_APP_ROOT # remove any zombie app left by an error
FileUtils.cp_r File.expand_path('../pristine_testapp',__FILE__), TEST_APP_ROOT
Dir.chdir( TEST_APP_ROOT )
require 'config/environment'
require 'rails/generators'
Rails::Generators.configure!

