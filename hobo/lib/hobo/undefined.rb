module Hobo

  class Undefined

    def initialize(*args)
      options = args.extract_options!
      @klass = args.first || Object
    end

    def hobo_undefined?
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
      raise UndefinedAccessError.new("call to: Hobo::Undefined##{name}")
    end

    undef_method :==

  end

end


