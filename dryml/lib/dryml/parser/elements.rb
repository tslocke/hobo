module Hobo::Dryml::Parser

  class Element < REXML::Element

    def initialize(*args)
      super
      @elements = Hobo::Dryml::Parser::Elements.new(self)
    end

    def dryml_name
      expanded_name.sub(/:.*/, "")
    end

    attr_accessor :start_tag_source, :source_offset

    attr_writer :has_end_tag
    def has_end_tag?
      @has_end_tag
    end

    def parameter_tag?
      expanded_name =~ /:$/
    end

  end

  class Elements < REXML::Elements

    # Override to ensure DRYML elements are created
    def add(element=nil)
      rv = nil
      if element.nil?
        Hobo::Dryml::Parser::Element.new("", self, @element.context)
      elsif not element.kind_of?(Element)
        Hobo::Dryml::Parser::Element.new(element, self, @element.context)
      else
        @element << element
        element.context = @element.context
        element
      end
    end

  end

end
