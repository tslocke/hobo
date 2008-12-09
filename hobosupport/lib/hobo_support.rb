module HoboSupport

  VERSION = "0.8.5"

end


# Some teeny fixes too diminutive to go elsewhere

class Object

  # Often nice to ask e.g. some_object.is_a?(Symbol, String)
  alias_method :is_a_without_multiple_args?, :is_a?
  def is_a?(*args)
    args.any? {|a| is_a_without_multiple_args?(a) }
  end

end


class String

  # Return the constant that this string refers to, or nil if ActiveSupport cannot load such a
  # constant. This is much safer than `rescue NameError`, as that will mask genuine NameErrors
  # that have been made in the code being loaded (#safe_constantize will not)
  def safe_constantize
    Object.class_eval self
  rescue NameError => e
    # Unforunately we have to rely on the error message to figure out which constant was missing.
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