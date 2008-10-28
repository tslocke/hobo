require 'rexml/xpath'

module Hobo
  
  module Dryml

    # DrymlDoc provides the facility to parse a directory tree of DRYML taglibs, building a collection of objects that provide metadata
    module DrymlDoc
      
      def self.load_taglibs(directory, taglib_class=DrymlDoc::Taglib)
        dryml_files = Dir["#{directory}/**/*.dryml"]

        dryml_files.map { |f| taglib_class.new(directory, f) }
      end
      
      class Taglib
        
        def initialize(home, filename)
          @name = filename.sub(/.dryml$/, '')[home.length+1..-1]
          @doc = Hobo::Dryml::Parser::Document.new(File.read(filename), filename)
          parse_tag_defs
        end
        
        attr_reader :name, :doc, :tag_defs
        
        def comment
          first_node = doc[0][0]
          doc.restore_erb_scriptlets(first_node.to_s.strip) if first_node.is_a?(REXML::Comment)
        end
        
        def comment_html
          Maruku.new(comment).to_html
        end
        
           
        private   
             
        def tagdef_class
          self.class.parent.const_get('TagDef')
        end
        
        def parse_tag_defs
          @tag_defs = []
          REXML::XPath.match(doc, '/*/*[@tag]').each { |node| @tag_defs << tagdef_class.new(self, node) }
        end
        
      end
      
      class TagDef
        
        def initialize(taglib, node)
          @taglib = taglib
          @node = node
        end
        
        attr_reader :taglib, :node
        delegate :doc, :to => :taglib
        
        
        def name
          node.attributes['tag']
        end
        
        def source
          doc.restore_erb_scriptlets(node.to_s).strip
        end
        
        # The contents of the XML comment, if any, immediately above the tag definition
        def comment
          @comment ||= begin
            space = node.previous_sibling and
              space.to_s.blank? && space.to_s.count("\n") == 1 and
              comment_node = space.previous_sibling

            if comment_node.is_a?(REXML::Comment)
              doc.restore_erb_scriptlets(comment_node.to_s.strip)
            end
          end
        end
        
        
        def comment_intro
          comment && comment =~ /(.*?)^#/m ? $1 : comment
        end

        
        def comment_rest
          comment && comment[comment_intro.length..-1]
        end

        %w(comment comment_intro comment_rest).each do |m|
          class_eval "def #{m}_html; Maruku.new(#{m}).to_html.gsub(/&amp;/, '&'); end"
        end
        
        def comment_html
          
        end
        
        def no_doc?
          comment =~ /^nodoc\b/
        end
        
        # An array of the arrtibute names defined by this tag
        def attributes
          (node.attributes['attrs'] || "").split(/\s*,\s*/).where_not.blank?
        end
        
        
        # Returns a recursive array srtucture, where each item in the array is a pair: [parameter_name, sub_parameters]
        # (sub-parameters is the same kind of structure)
        def parameters(element=node)
          result = []
          element.elements.each do |e|
            if (p = e.attributes['param'])
              param_name = p == "&true" ? e.name : p
              result << [param_name, parameters(e)]
            else
              result.concat(parameters(e))
            end
          end
          result
        end
        
        
        # Is this the base definition of a polymorphic tag
        def polymorphic?
          node.attributes['polymorphic'].present?
        end
        
        # Is this an <extend>?
        def extension?
          node.name == "extend"
        end
        
        
        # The definition's 'for' attribute
        def for_type
          node.attributes['for']
        end
        

        # The name of the tag, if any, that this definition merges its parameters into
        # That is, the tag with 'merge' or 'merge-params' declared
        def merge_params
          REXML::XPath.first(node, ".//*[@merge|@merge-params]")._?.name
        end
        
        # The name of the tag, if any, that this definition merges its attributes into
        # That is, the tag with 'merge' or 'merge-attrs' declared        
        def merge_attrs
          REXML::XPath.first(node, ".//*[@merge|@merge-attrs]")._?.name
        end
        
      end
      
      
    end
    
  end
  
end