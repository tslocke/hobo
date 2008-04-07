module Hobo::Dryml::Parser
  
  class Document < REXML::Document        
    
    attr_accessor :default_attribute_value
    
    def initialize(source=nil, context={})
      super(nil, context)
      @elements = Hobo::Dryml::Parser::Elements.new(self)
      if source.kind_of? Document
        @context = source.context
        super source
      else
        build(  source )
      end 
    end
    

    private
    def build( source )
      Hobo::Dryml::Parser::TreeParser.new( source, self ).parse
    end
    
  end
  
end
