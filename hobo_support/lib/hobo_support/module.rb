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
  # if not defined on self. Default values can be a Proc object that takes the class as a parameter.
  def inheriting_cattr_reader(*names)
    names_with_defaults = (names.pop if names.last.is_a?(Hash)) || {}

    (names + names_with_defaults.keys).each do |name|
      ivar_name = "@#{name}"
      block = names_with_defaults[name]
      self.send(self.class == Module ? :define_method : :meta_def, name) do
        if instance_variable_defined? ivar_name
          instance_variable_get(ivar_name)
        else
          superclass.respond_to?(name) && superclass.send(name) ||
          block && begin
            result = block.is_a?(Proc) ? block.call(self) : block
            instance_variable_set(ivar_name, result) if result
          end
        end
      end
    end
  end

  def inheriting_cattr_accessor(*names)
    names_with_defaults = (names.pop if names.last.is_a?(Hash)) || {}

    names_with_defaults.keys.each do |name|
      attr_writer name
      inheriting_cattr_reader names_with_defaults.slice(name)
    end
    names.each do |name|
      attr_writer name
      inheriting_cattr_reader name
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
