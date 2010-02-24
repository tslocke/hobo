module HoboSupport

  VERSION = "1.1.0.pre0"

  RAILS_VERSION_FLOAT = Object.const_defined?(:Rails) ? Rails::VERSION::STRING.match(/^\d+\.\d+/)[0].to_f : 0
  
  RAILS_AT_LEAST_23 = (RAILS_VERSION_FLOAT >= 2.3)

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
