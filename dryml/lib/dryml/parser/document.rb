module Hobo::Dryml

  module Parser

    class Document < REXML::Document

      def initialize(source, path)
        super(nil)

        # Replace <%...%> scriptlets with xml-safe references into a hash of scriptlets
        @scriptlets = {}
        source = source.gsub(/<%(.*?)%>/m) do
          _, scriptlet = *Regexp.last_match
          id = @scriptlets.size + 1
          @scriptlets[id] = scriptlet
          newlines = "\n" * scriptlet.count("\n")
          "[![DRYML-ERB#{id}#{newlines}]!]"
        end


        @reference_src = "<dryml_page>" + source + "</dryml_page>"
        rex_src = Hobo::Dryml::Parser::Source.new(@reference_src)

        @elements = Hobo::Dryml::Parser::Elements.new(self)
        build(rex_src)

      rescue REXML::ParseException => e
        raise Hobo::Dryml::DrymlSyntaxError, "File: #{path}\n#{e}"
      end


      def element_line_num(el)
        offset = el.source_offset
        @reference_src[0..offset].count("\n") + 1
      end


      def default_attribute_value
        "&true"
      end


      def restore_erb_scriptlets(src)
        src.gsub(/\[!\[DRYML-ERB(\d+)\s*\]!\]/m) {|s| "<%#{@scriptlets[$1.to_i]}%>" }
      end


      private
      def build( source )
        Hobo::Dryml::Parser::TreeParser.new( source, self ).parse
      end

    end

  end

end
