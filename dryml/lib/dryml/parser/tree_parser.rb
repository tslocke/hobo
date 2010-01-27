module Hobo::Dryml::Parser

  class TreeParser < REXML::Parsers::TreeParser
    def initialize( source, build_context = Document.new )
      @build_context = build_context
      @parser = Hobo::Dryml::Parser::BaseParser.new(source)
    end


    def parse
      tag_stack = []
      in_doctype = false
      entities = nil
      begin
        while true
          event = @parser.pull
          #STDERR.puts "TREEPARSER GOT #{event.inspect}"
          case event[0]
          when :end_document
            unless tag_stack.empty?
              #raise ParseException.new("No close tag for #{tag_stack.inspect}")
              raise ParseException.new("No close tag for #{@build_context.xpath}")
            end
            return
          when :start_element
            tag_stack.push(event[1])
            el = @build_context = @build_context.add_element( event[1] )
            event[2].each do |key, value|
              el.attributes[key]=Hobo::Dryml::Parser::Attribute.new(key,value,self)
            end
            @build_context.start_tag_source = event[3]
            @build_context.source_offset = event[4]
          when :end_element
            tag_stack.pop
            @build_context.has_end_tag = event[2]
            @build_context = @build_context.parent
          when :text
            if not in_doctype
              if @build_context[-1].instance_of? Text
                @build_context[-1] << event[1]
              else
                @build_context.add(
                                   Hobo::Dryml::Parser::Text.new(event[1], @build_context.whitespace, nil, true)
                                   ) unless (
                                             @build_context.ignore_whitespace_nodes and
                                             event[1].strip.size==0
                                             )
              end
            end
          when :comment
            c = REXML::Comment.new( event[1] )
            @build_context.add( c )
          when :cdata
            c = REXML::CData.new( event[1] )
            @build_context.add( c )
          when :processing_instruction
            @build_context.add( Instruction.new( event[1], event[2] ) )
          end
        end
      rescue REXML::Validation::ValidationException
        raise
      rescue
        raise REXML::ParseException.new( $!.message, @parser.source, @parser, $! )
      end
    end
  end
end
