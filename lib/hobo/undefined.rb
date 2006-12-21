module Hobo

  class Undefined

    def initialize(klass=Object)
      @klass = klass
    end

    def undefined?
      true
    end

    def class
      @klass
    end

    def is_a?(klass)
      return klass == @klass || klass > @klass
    end

    def to_s
      "<Hobo::Undefined #{@klass}>"
    end

    def inspect
      to_s
    end

    def new_record?
      true
    end

    def method_missing(name, *args)
      raise UndefinedAccessError.new("call to: #{name}")
    end

  end

end
