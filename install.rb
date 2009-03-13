require 'fileutils'

HOBO_CONTRIB_HOME = File.dirname(__FILE__)

FileUtils.cp "#{HOBO_CONTRIB_HOME}/public/javascripts/hobo-jquery.js", "#{RAILS_ROOT}/public/javascripts/hobo-jquery.js"
FileUtils.cp "#{HOBO_CONTRIB_HOME}/public/stylesheets/hobo-jquery.css", "#{RAILS_ROOT}/public/stylesheets/hobo-jquery.js"
