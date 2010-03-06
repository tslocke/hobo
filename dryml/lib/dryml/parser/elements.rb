module Dryml::Parser

  class Elements < REXML::Elements

    # Override to ensure DRYML elements are created
    def add(element=nil)
      rv = nil
      if element.nil?
        Dryml::Parser::Element.new("", self, @element.context)
      elsif not element.kind_of?(Element)
        Dryml::Parser::Element.new(element, self, @element.context)
      else
        @element << element
        element.context = @element.context
        element
      end
    end

  end

end
