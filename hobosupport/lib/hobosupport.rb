require 'activesupport'

require "hobosupport/fixes"
require 'hobosupport/blankslate'
require 'hobosupport/methodcall'
require 'hobosupport/methodphitamine'
require 'hobosupport/metaid'
require 'hobosupport/implies'
require 'hobosupport/enumerable'
require 'hobosupport/array'
require 'hobosupport/hash'
require 'hobosupport/module'

module HoboSupport
  
  VERSION = "0.7.5"
  
end


# Some teeny fixes too diminutive to go elsewhere

class Object

  # Often nice to ask e.g. some_object.is_a?(Symbol, String)
  alias_method :is_a_without_multiple_args?, :is_a?
  def is_a?(*args)
    args.any? {|a| is_a_without_multiple_args?(a) }
  end
  
end
