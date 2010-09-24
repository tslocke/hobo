require 'active_support'
require 'active_support/core_ext'
require 'active_support/dependencies'

require "hobo_support/fixes/chronic"
require "hobo_support/fixes/pp"
require "hobo_support/fixes/module"
require 'hobo_support/blankslate'
require 'hobo_support/methodcall'
require 'hobo_support/methodphitamine'
require 'hobo_support/metaid'
require 'hobo_support/implies'
require 'hobo_support/enumerable'
require 'hobo_support/array'
require 'hobo_support/hash'
require 'hobo_support/module'
require 'hobo_support/string'
require 'hobo_support/xss'
require 'hobo_support/kernel'

module HoboSupport

  VERSION = File.read(File.expand_path('../../VERSION', __FILE__)).strip

end
