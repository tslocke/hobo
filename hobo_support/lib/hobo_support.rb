require 'active_support'
require 'active_support/core_ext'
require 'active_support/dependencies'

require "hobo_support/fixes"
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

module HoboSupport

  VERSION = "1.3.0.pre3"

end


# Some teeny bit and bobs too diminutive to go elsewhere

class Object

  def is_one_of?(*args)
    args.any? {|a| is_a?(a) }
  end

end


class String

  # Return the constant that this string refers to, or nil if ActiveSupport cannot load such a
  # constant. This is much safer than `rescue NameError`, as that will mask genuine NameErrors
  # that have been made in the code being loaded (#safe_constantize will not)
  def safe_constantize
    Object.class_eval self
  rescue NameError => e
    # Unfortunately we have to rely on the error message to figure out which constant was missing.
    # NameError has a #name method but it is always nil
    if e.message !~ /\b#{self}$/
      # oops - some other name error
      raise
    else
      nil
    end
  end

end

module Kernel

  def dbg(*args)
    puts "---DEBUG---"
    args.each do |a|
      if a.is_a?(String) && a =~ /\n/
        puts %("""\n) + a + %(\n"""\n)
      else
        p a
      end
    end
    puts "-----------"
    args.first
  end

end
