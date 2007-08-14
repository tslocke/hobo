# Extensions to XML Parsing
#
# 1. Hobo needs to process XML as transparently as possibe. In the
# case of tags that are not defined (i.e. html tags), they should pass
# through just as they were in the dryml source. Recontructing the
# tags from the DOM is not good enough. The extensions to REXML in
# here allow Hobo to use the original start tag source in the output.
#
# 2. some fixes/extras to allow error messages with line numbers.
#
# 3. Attributes without a RHS are allowed. They are returned as having
# a value of +true+ (the Ruby value, not the string 'true')
#
# 1 and 2 are achieved by adding two instance variables to Element
# nodes : @start_tag_source and @source_offset
#
# So cool that Ruby allows us to redefine a method. Such a shame the method
# we needed to change happened to be 200 lines long :-(

require 'rexml/document'



module REXML
  module Parsers

    class TreeParser
      def initialize( source, build_context = Document.new )
        @build_context = build_context
        @parser = Parsers::BaseParser.new(source)
        @parser.dryml_mode = build_context.context[:dryml_mode]
      end
    end
    
    class BaseParser
      
      DRYML_ATTRIBUTE_PATTERN = /\s*(#{NAME_STR}\??)(?:\s*=\s*(["'])(.*?)\2)?/um
      
      DRYML_TAG_MATCH = /^<((?>#{NAME_STR}))\s*((?>\s+#{NAME_STR}(?:\s*=\s*(["']).*?\3)?)*)\s*(\/)?>/um
      
      attr_writer :dryml_mode
      def dryml_mode?
        @dryml_mode
      end
      
      
      def pull
        if @closed
          x, @closed = @closed, nil
          return [ :end_element, x, false ]
        end
        return [ :end_document ] if empty?
        return @stack.shift if @stack.size > 0
        @source.read if @source.buffer.size<2
        if @document_status == nil
          @source.consume(/^\s*/um)
          word = @source.match(/(<[^>]*)>/um)
          word = word[1] unless word.nil?
          case word
          when COMMENT_START
            return [ :comment, @source.match(COMMENT_PATTERN, true)[1] ]
          when XMLDECL_START
            results = @source.match(XMLDECL_PATTERN, true)[1]
            version = VERSION.match(results)
            version = version[1] unless version.nil?
            encoding = ENCODING.match(results)
            encoding = encoding[1] unless encoding.nil?
            @source.encoding = encoding
            standalone = STANDALONE.match(results)
            standalone = standalone[1] unless standalone.nil?
            return [ :xmldecl, version, encoding, standalone]
          when INSTRUCTION_START
            return [ :processing_instruction, *@source.match(INSTRUCTION_PATTERN, true)[1,2] ]
          when DOCTYPE_START
            md = @source.match(DOCTYPE_PATTERN, true)
            identity = md[1]
            close = md[2]
            identity =~ IDENTITY
            name = $1
            raise REXML::ParseException("DOCTYPE is missing a name") if name.nil?
            pub_sys = $2.nil? ? nil : $2.strip
            long_name = $3.nil? ? nil : $3.strip
            uri = $4.nil? ? nil : $4.strip
            args = [ :start_doctype, name, pub_sys, long_name, uri ]
            if close == ">"
              @document_status = :after_doctype
              @source.read if @source.buffer.size<2
              md = @source.match(/^\s*/um, true)
              @stack << [ :end_doctype ]
            else
              @document_status = :in_doctype
            end
            return args
          else
            @document_status = :after_doctype
            @source.read if @source.buffer.size<2
            md = @source.match(/\s*/um, true)
          end
        end
        if @document_status == :in_doctype
          md = @source.match(/\s*(.*?>)/um)
          case md[1]
          when SYSTEMENTITY 
            match = @source.match(SYSTEMENTITY, true)[1]
            return [ :externalentity, match ]

          when ELEMENTDECL_START
            return [ :elementdecl, @source.match(ELEMENTDECL_PATTERN, true)[1] ]

          when ENTITY_START
            match = @source.match(ENTITYDECL, true).to_a.compact
            match[0] = :entitydecl
            ref = false
            if match[1] == '%'
              ref = true
              match.delete_at 1
            end
            # Now we have to sort out what kind of entity reference this is
            if match[2] == 'SYSTEM'
              # External reference
              match[3] = match[3][1..-2] # PUBID
              match.delete_at(4) if match.size > 4 # Chop out NDATA decl
              # match is [ :entity, name, SYSTEM, pubid(, ndata)? ]
            elsif match[2] == 'PUBLIC'
              # External reference
              match[3] = match[3][1..-2] # PUBID
              match[4] = match[4][1..-2] # HREF
              # match is [ :entity, name, PUBLIC, pubid, href ]
            else
              match[2] = match[2][1..-2]
              match.pop if match.size == 4
              # match is [ :entity, name, value ]
            end
            match << '%' if ref
            return match
          when ATTLISTDECL_START
            md = @source.match(ATTLISTDECL_PATTERN, true)
            raise REXML::ParseException.new("Bad ATTLIST declaration!", @source) if md.nil?
            element = md[1]
            contents = md[0]

            pairs = {}
            values = md[0].scan(ATTDEF_RE)
            values.each do |attdef|
              unless attdef[3] == "#IMPLIED"
                attdef.compact!
                val = attdef[3]
                val = attdef[4] if val == "#FIXED "
                pairs[attdef[0]] = val
              end
            end
            return [ :attlistdecl, element, pairs, contents ]
          when NOTATIONDECL_START
            md = nil
            if @source.match(PUBLIC)
              md = @source.match(PUBLIC, true)
            elsif @source.match(SYSTEM)
              md = @source.match(SYSTEM, true)
            else
              raise REXML::ParseException.new("error parsing notation: no matching pattern", @source)
            end
            return [ :notationdecl, md[1], md[2], md[3] ]
          when CDATA_END
            @document_status = :after_doctype
            @source.match(CDATA_END, true)
            return [ :end_doctype ]
          end
        end
        begin
          if @source.buffer[0] == ?<
            if @source.buffer[1] == ?/
              last_tag, line_no = @tags.pop
              #md = @source.match_to_consume('>', CLOSE_MATCH)
              md = @source.match(CLOSE_MATCH, true)
              
              valid_end_tag = if dryml_mode?
                                last_tag =~ /^#{Regexp.escape(md[1])}(:.*)?/
                              else
                                last_tag == md[1]
                              end
              raise REXML::ParseException.new("Missing end tag for "+
                                              "'#{last_tag}' (line #{line_no}) (got \"#{md[1]}\")", 
                                              @source) unless valid_end_tag
              return [ :end_element, last_tag, true ]
            elsif @source.buffer[1] == ?!
              md = @source.match(/\A(\s*[^>]*>)/um)
              raise REXML::ParseException.new("Malformed node", @source) unless md
              if md[0][2] == ?-
                md = @source.match(COMMENT_PATTERN, true)
                return [ :comment, md[1] ] if md
              else
                md = @source.match(CDATA_PATTERN, true)
                return [ :cdata, md[1] ] if md
              end
              raise REXML::ParseException.new("Declarations can only occur "+
                "in the doctype declaration.", @source)
            elsif @source.buffer[1] == ??
              md = @source.match(INSTRUCTION_PATTERN, true)
              return [ :processing_instruction, md[1], md[2] ] if md
              raise REXML::ParseException.new("Bad instruction declaration",
                @source)
            else
              # Get the next tag
              md = @source.match(dryml_mode? ? DRYML_TAG_MATCH : TAG_MATCH, true)
              raise REXML::ParseException.new("malformed XML: missing tag start", @source) unless md
              attrs = []
              if md[2].size > 0
                attrs = md[2].scan(dryml_mode? ? DRYML_ATTRIBUTE_PATTERN : ATTRIBUTE_PATTERN)
                raise REXML::ParseException.new("error parsing attributes: [#{attrs.join ', '}], excess = \"#$'\"",
                                                @source) if $' and $'.strip.size > 0
              end
        
              if md[4]
                @closed = md[1]
              else
                cl = @source.current_line
                @tags.push([md[1], cl && cl[2]])
              end
              attributes = {}
              attrs.each { |a,b,c| attributes[a] = (c || true) }
              return [ :start_element, md[1], attributes, md[0],
                       @source.respond_to?(:last_match_offset) && @source.last_match_offset ]
            end
          else
            md = @source.match(TEXT_PATTERN, true)
            if md[0].length == 0
              @source.match(/(\s+)/, true)
            end
            #return [ :text, "" ] if md[0].length == 0
            # unnormalized = Text::unnormalize(md[1], self)
            # return PullEvent.new(:text, md[1], unnormalized)
            return [ :text, md[1] ]
          end
        rescue REXML::ParseException
          raise
        rescue Exception, NameError => error
          raise REXML::ParseException.new("Exception parsing", @source, self, (error ? error : $!))
        end
        return [ :dummy ]
      end
    end

    class TreeParser
      def parse
        tag_stack = []
        in_doctype = false
        entities = nil
        begin
          while true
            event = @parser.pull
            case event[0]
            when :end_document
              return
            when :start_element
              tag_stack.push(event[1])
              # find the observers for namespaces
              @build_context = @build_context.add_element(event[1], event[2])
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
                    Text.new(event[1], @build_context.whitespace, nil, true) 
                 ) unless (
                    event[1].strip.size==0 and 
                    @build_context.ignore_whitespace_nodes
                 )
                end
              end
            when :comment
              c = Comment.new(event[1])
              @build_context.add(c)
            when :cdata
              c = CData.new(event[1])
              @build_context.add(c)
            when :processing_instruction
              @build_context.add(Instruction.new(event[1], event[2]))
            when :end_doctype
              in_doctype = false
              entities.each { |k,v| entities[k] = @build_context.entities[k].value }
              @build_context = @build_context.parent
            when :start_doctype
              doctype = DocType.new(event[1..-1], @build_context)
              @build_context = doctype
              entities = {}
              in_doctype = true
            when :attlistdecl
              n = AttlistDecl.new(event[1..-1])
              @build_context.add(n)
            when :externalentity
              n = ExternalEntity.new(event[1])
              @build_context.add(n)
            when :elementdecl
              n = ElementDecl.new(event[1])
              @build_context.add(n)
            when :entitydecl
              entities[ event[1] ] = event[2] unless event[2] =~ /PUBLIC|SYSTEM/
              @build_context.add(Entity.new(event))
            when :notationdecl
              n = NotationDecl.new(*event[1..-1])
              @build_context.add(n)
            when :xmldecl
              x = XMLDecl.new(event[1], event[2], event[3])
              @build_context.add(x)
            end
          end
        rescue REXML::Validation::ValidationException
          raise
        rescue
          raise ParseException.new($!.message, @parser.source, @parser, $!)
        end
      end
    end
  end
  
  class Document
    
    attr_accessor :default_attribute_value
    
  end
  
  class Element
    
    def dryml_name
      expanded_name.sub(/:.*/, "")
    end
    
    attr_accessor :start_tag_source, :source_offset
    
    attr_writer :has_end_tag
    def has_end_tag?
      @has_end_tag
    end
    
  end
  
  class Attribute
    
    def initialize_with_dryml(first, second=nil, parent=nil)
      initialize_without_dryml(first, second, parent)
      if first.is_a?(String) && second == true
        @value = true
      end
    end
    alias_method_chain :initialize, :dryml
    
    def value_with_dryml
      if has_rhs?
        value_without_dryml
      else
        element.document.default_attribute_value
      end
    end
    alias_method_chain :value, :dryml

    def to_string_with_dryml
      if has_rhs?
        to_string_without_dryml
      else
        @expanded_name
      end
    end
    alias_method_chain :to_string, :dryml
    
    def has_rhs?
      @value != true
    end
    
  end

end

module Hobo::Dryml

  class RexSource < REXML::Source
    
    def initialize(src)
      super(src)
      @buffer_offset = 0
    end

    attr_reader :last_match_offset

    def remember_match(m)
      if m
        @last_match = m
        @last_match_offset = @buffer_offset + m.begin(0)
        @orig[@last_match_offset..@last_match_offset+m[0].length] == @buffer[m.begin(0)..m.end(0)]
      end
      m
    end

    def advance_buffer(md)
      @buffer = md.post_match
      @buffer_offset += md.end(0)
    end

    def scan(pattern, cons=false)
      raise '!'
      return nil if @buffer.nil?
      rv = @buffer.scan(pattern)
      if cons and rv.size > 0
        advance_buffer(Regexp.last_match)
      end
      rv
    end

    def consume(pattern)
      md = remember_match(pattern.match(@buffer))
      if md
        advance_buffer(md)
        @buffer
      end
    end

    def match(pattern, cons=false)
      md = remember_match(pattern.match(@buffer))
      advance_buffer(md) if cons and md
      return md
    end

    def current_line
      pos = last_match_offset || 0
      [0, 0, @orig[0..pos].count("\n") + 1] 
    end

  end
    
end
