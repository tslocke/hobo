module Hobo::Dryml::Parser

  class Attribute < REXML::Attribute

    def initialize(first, second=nil, parent=nil)
      super
      if first.is_a?(String) && second == true
        @value = true
      end
    end

    def value
      if has_rhs?
        super
      else
        element.document.default_attribute_value
      end
    end

    def to_string
      if has_rhs?
        super
      else
        @expanded_name
      end
    end

    def has_rhs?
      @value != true
    end


    # Override to supress Text.check call
    def element=( element )
      @element = element
      self
    end

  end

end
