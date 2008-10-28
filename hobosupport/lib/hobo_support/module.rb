class Module

  private

  # In a module definition you can include a call to
  # included_in_class_callbacks(base) at the end of the
  # self.included(base) callback. Any modules that your module includes
  # will receive an included_in_class callback when your module is
  # included in a class. Useful if the sub-module wants to do something
  # like alias_method_chain on the class.
  def included_in_class_callbacks(base)
    if base.is_a?(Class)
      included_modules.each { |m| m.try.included_in_class(base) }
    end
  end

  # Creates a class attribute reader that will delegate to the superclass
  # if not defined on self
  def inheriting_cattr_reader(*names)
    names_with_defaults = (names.pop if names.last.is_a?(Hash)) || {}

    names_with_defaults.each do |name, default|
      instance_variable_set("@#{name}", default) unless instance_variable_get("@#{name}") != nil || superclass.respond_to?(name)
    end

    (names + names_with_defaults.keys).each do |name|
      class_eval %{
        def self.#{name}
          if defined? @#{name}
            @#{name}
          elsif superclass.respond_to?('#{name}')
            superclass.#{name}
          end
        end
      }
    end
  end

  # creates a #foo= and #foo? pair, with optional default values, e.g.
  # bool_attr_accessor :happy => true
  def bool_attr_accessor(*args)
    options = (args.pop if args.last.is_a?(Hash)) || {}

    (args + options.keys).each {|n| class_eval "def #{n}=(x); @#{n} = x; end" }

    args.each {|n| class_eval "def #{n}?; @#{n}; end" }

    options.keys.each do |n|
      class_eval %(def #{n}?
                     if !defined? @#{n}
                       @#{n} = #{options[n] ? 'true' : 'false'}
                     else
                       @#{n}
                     end
                   end)
      set_field_type(n => TrueClass) if respond_to?(:set_field_type)
    end
  end

  def alias_class_method_chain(method, feature)
    meta_eval do
      alias_method_chain method, feature
    end
  end

end


# classy_module lets you extract code from classes into modules, but
# still write it the same way
module Kernel

  def classy_module(mod=Module.new, &b)
    mod.meta_def :included do |base|
      base.class_eval &b
    end
    mod
  end

end
