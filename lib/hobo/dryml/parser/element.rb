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

end
