require 'rexml/document'

module Hobo::Dryml

  class Template

    DRYML_NAME = "[a-zA-Z_][a-zA-Z0-9_]*"
    DRYML_NAME_RX = /^#{DRYML_NAME}$/
    
    CODE_ATTRIBUTE_CHAR = "&"

    @build_cache = {}
    
    class << self
      attr_reader :build_cache

      def clear_build_cache
        @build_cache.clear()
      end
    end

    def initialize(src, environment, template_path)
      @src = src

      @environment = environment # a class or a module

      @template_path = template_path.sub(/^#{Regexp.escape(RAILS_ROOT)}/, "")

      @builder = Template.build_cache[@template_path] || DRYMLBuilder.new(@template_path)
      @builder.set_environment(environment)

      @last_element = nil
    end

    attr_reader :tags, :template_path
    
    def compile(local_names=[], auto_taglibs=[])
      now = Time.now

      unless @template_path == EMPTY_PAGE
        filename = RAILS_ROOT + (@template_path.starts_with?("/") ? @template_path : "/" + @template_path)
        mtime = File.stat(filename).mtime rescue nil
      end
        
      if mtime.nil? || !@builder.ready?(mtime)
        @builder.clear_instructions
        parsed = true
        # parse the DRYML file creating a list of build instructions
        if is_taglib?
          process_src
        else
          create_render_page_method
        end

        # store build instructions in the cache
        Template.build_cache[@template_path] = @builder
      end

      # compile the build instructions
      @builder.build(local_names, auto_taglibs)

      from_cache = (parsed ? '' : ' (from cache)')
      logger.info("  DRYML: Compiled#{from_cache} #{template_path} in %.2fs" % (Time.now - now))
    end
      

    def create_render_page_method
      erb_src = process_src
      @builder.add_build_instruction(:render_page, :src => process_src, :line_num => 1)
    end

    
    def is_taglib?
      @environment.class == Module
    end

    
    def process_src
      # Replace <%...%> scriptlets with xml-safe references into a hash of scriptlets
      @scriptlets = {}
      src = @src.gsub(/<%(.*?)%>/m) do
        _, scriptlet = *Regexp.last_match
        id = @scriptlets.size + 1
        @scriptlets[id] = scriptlet
        newlines = "\n" * scriptlet.count("\n")
        "[![HOBO-ERB#{id}#{newlines}]!]"
      end

      @xmlsrc = "<dryml_page>" + src + "</dryml_page>"
      @doc = REXML::Document.new(RexSource.new(@xmlsrc), :dryml_mode => true)
      @doc.default_attribute_value = "&true"
      
      restore_erb_scriptlets(children_to_erb(@doc.root))
    end


    def restore_erb_scriptlets(src)
      src.gsub(/\[!\[HOBO-ERB(\d+)\s*\]!\]/m) {|s| "<%#{@scriptlets[$1.to_i]}%>" }
    end

    
    def children_to_erb(nodes)
      nodes.map{|x| node_to_erb(x)}.join
    end
 

    def node_to_erb(node)
      case node

      # v important this comes before REXML::Text, as REXML::CData < REXML::Text
      when REXML::CData
        REXML::CData::START + node.to_s + REXML::CData::STOP
        
      when REXML::Comment
        REXML::Comment::START + node.to_s + REXML::Comment::STOP

      when REXML::Text
        node.to_s

      when REXML::Element
        element_to_erb(node)
      end
    end


    def element_to_erb(el)
      dryml_exception("parameter tags (<#{el.name}>) are no more, wake up and smell the coffee", el) if
        el.name.starts_with?(":")

      @last_element = el
      case el.dryml_name

      when "include"
        include_element(el)
        # return nothing - the include has no presence in the erb source
        tag_newlines(el)
        
      when "set_theme"
        require_attribute(el, "name", /^#{DRYML_NAME}$/)
        @builder.add_build_instruction(:set_theme, :name => el.attributes['name'])

        # return nothing - set_theme has no presence in the erb source
        tag_newlines(el)

      when "def"
        def_element(el)
        
      when "tagbody"
        tagbody_element(el)
        
      when "set"
        set_element(el)

      else
        if el.dryml_name.not_in?(Hobo.static_tags) or el.attributes['merge']
          if el.dryml_name =~ /^[A-Z]/
            template_call(el)
          else
            tag_call(el)
          end
        else
          static_element_to_erb(el)
        end
      end
    end


    def include_element(el)
      require_toplevel(el)
      require_attribute(el, "as", /^#{DRYML_NAME}$/, true)
      if el.attributes["src"]
        @builder.add_build_instruction(:include, 
                                       :name => el.attributes["src"], 
                                       :as => el.attributes["as"])
      elsif el.attributes["module"]
        @builder.add_build_instruction(:module, 
                                       :name => el.attributes["module"], 
                                       :as => el.attributes["as"])
      end
    end
    

    def import_module(mod, as=nil)
      @builder.import_module(mod, as)
    end


    def redefine_element(el)
      redefined_tags = el.children.
        select {|e| e.is_a?(REXML::Element) && e.name == "def"}.
        map {|e| Hobo::Dryml.unreserve(e.attributes["tag"]) }
      "<% self.class.start_redefine_block(#{redefined_tags.inspect}) #{tag_newlines(el)} %>" +
        children_to_erb(el) +
        "<% self.class.end_redefine_block %>"
    end
    
    
    def set_element(el)
      el.attributes.map do |name, value|
        dryml_exception(el, "invalid name in set") unless name =~ DRYML_NAME_RX
        "<% #{name} = #{attribute_to_ruby(value)}; %>"
      end.join + tag_newlines(el)
    end


    def def_element(el)
      redefine = el.parent.name == "def"
      
      require_toplevel(el, "must be at the top-level or directly inside a <def>") unless redefine
      require_attribute(el, "tag", DRYML_NAME_RX)
      require_attribute(el, "attrs", /^\s*#{DRYML_NAME}(\s*,\s*#{DRYML_NAME})*\s*$/, true)
      require_attribute(el, "alias_of", DRYML_NAME_RX, true)
      require_attribute(el, "alias_current", DRYML_NAME_RX, true)

      unsafe_name = el.attributes["tag"]
      name = Hobo::Dryml.unreserve(unsafe_name)

      alias_of = el.attributes['alias_of']
      alias_current = el.attributes['alias_current']

      dryml_exception("def cannot have both alias_of and alias_current", el) if alias_of && alias_current
      dryml_exception("def with alias_of must be empty", el) if alias_of and el.size > 0
      
      # If we're redefining, we need a statement in the method body
      # that does the alias_method on the fly.
      re_alias = ""
      
      if alias_of || alias_current
        old_name = alias_current ? name : alias_of
        new_name = alias_current ? alias_current : name

        if redefine
          re_alias = "<% self.class.send(:alias_method, :#{new_name}, :#{old_name}) %>"
        else
          @builder.add_build_instruction(:alias_method, :new => new_name.to_sym, :old => old_name.to_sym)
        end
      end
      
      if alias_of
        "#{re_alias}<% #{tag_newlines(el)} %>"
      else
        attrspec = el.attributes["attrs"]
        attr_names = attrspec ? attrspec.split(/\s*,\s*/).every(:to_sym) : []
        
        invalids = attr_names & [:with, :field, :this]
        dryml_exception("invalid attrs in def: #{invalids * ', '}", el) unless invalids.empty?
        
        src = if template_name?(name)
                method_body = tag_method_body(el, attr_names)
                template_method(name, re_alias, redefine, method_body)
              else
                method_body = tag_method_body(el, attr_names)
                tag_method(name, re_alias, redefine, method_body)
              end
        src << "<% _register_tag_attrs(:#{name}, #{attr_names.inspect}) %>"
        
        logger.debug(restore_erb_scriptlets(src)) if el.attributes["debug_source"]
        
        @builder.add_build_instruction(:def,
                                       :src => restore_erb_scriptlets(src),
                                       :line_num => element_line_num(el))
        # keep line numbers matching up
        "<% #{"\n" * method_body.count("\n")} %>"
      end
    end
    
    
    def template_call?(el)
      template_name?(el.name)
    end
    
    
    def template_name?(name)
      name =~ /^[A-Z]/
    end
    
    
    def template_method(name, re_alias, redefine, method_body)
      if redefine
        re_alias + "<% self.class.redefine_tag(:#{name}, proc {|__options__, template_procs, __block__| " +
          ("#{@def_name}_tagbody = tagbody; " if @def_name).to_s + "__res__ = #{method_body} " +
          ("; tagbody = #{@def_name}_tagbody; __res__; " if @def_name).to_s + "}); %>"
      else
        "<% def #{name}(__options__={}, template_procs={}, &__block__); #{method_body}; end %>"
      end
    end
    
    
    def tag_method(name, re_alias, redefine, method_body)
      if redefine
        re_alias + "<% self.class.redefine_tag(:#{name}, proc {|__options__, __block__| " +
          ("#{@def_name}_tagbody = tagbody; " if @def_name).to_s + "__res__ = #{method_body} " +
          ("; tagbody = #{@def_name}_tagbody; __res__; " if @def_name).to_s + "}); %>"
      else
        "<% def #{name}(__options__={}, &__block__); #{method_body}; end %>"
      end
    end
              
    
    def tag_method_body(el, attrs)
      # A statement to assign values to local variables named after the tag's attrs
      # The trailing comma on `options` is supposed to be there!
      setup_locals = attrs.map{|a| "#{Hobo::Dryml.unreserve(a)}, "}.join + "options, = " +
        "_tag_locals(__options__, #{attrs.inspect})"

      start = "_tag_context(__options__, __block__) do |tagbody| #{setup_locals}"
      
      # While processing the children of this def, @def_name contains
      # the names of all nested defs join with '_'. It's used to
      # disambiguate the +tagbody+ local variables.
      old_def_name = @def_name
      unsafe_name = el.attributes['tag']
      @def_name = @def_name ? "#{@def_name}_#{unsafe_name}" : unsafe_name

      res = "#{start} " +
        # reproduce any line breaks in the start-tag so that line numbers are preserved
        tag_newlines(el) + "%>" +
        children_to_erb(el) +
        "<% _erbout; end"
      @def_name = old_def_name
      res
    end
    
    
    def tagbody_element(el)
      dryml_exception("tagbody can only appear inside a <def>", el) unless
        find_ancestor(el) {|e| e.name == 'def'}
      dryml_exception("tagbody cannot appear inside a part", el) if
        find_ancestor(el) {|e| e.attributes['part']}
      tagbody_call(el)
    end


    def tagbody_call(el)
      options = []
      with = el.attributes['with']
      field = el.attributes['field']
      options << ":with => #{attribute_to_ruby(with)}" if with
      options << ":field => #{attribute_to_ruby(field)}" if field
      else_ = attribute_to_ruby(el.attributes['else'])
      "<%= tagbody ? tagbody.call({ #{options * ', '} }) : #{else_} %>"
    end


    def part_element(el, content)
      require_attribute(el, "part", DRYML_NAME_RX)
      part_name  = el.attributes['part']
      dom_id = el.attributes['id'] || part_name
      
      part_src = "<% def #{part_name}_part #{tag_newlines(el)}; new_context do %>" +
        content +
        "<% end; end %>"
      @builder.add_part(part_name, restore_erb_scriptlets(part_src), element_line_num(el))

      newlines = "\n" * part_src.count("\n")
      "<%= call_part(#{attribute_to_ruby(dom_id)}, :#{part_name}) #{newlines} %>"
    end
    
    
    def extract_merge_name!(el)
      merge_name = el.attributes["merge"]
      
      if merge_name
        def_tag = find_ancestor(el) {|e| e.name == "def"}
        dryml_exception("merge is not allowed outside of template definitions", el) if
          def_tag.nil? || !template_name?(def_tag.attributes["tag"])
      end
      
      el.attributes.delete("merge")
      res = merge_name == "&true" ? el.dryml_name : merge_name

      dryml_exception("merge name for a template call must be capitalised", el) if
        res && template_call?(el) && !template_name?(res)
      dryml_exception("merge name for a block-tag call must not be capitalised", el) if
        res && !template_call?(el) && template_name?(res)
      
      res
    end
    
    
    def call_name(el)
      Hobo::Dryml.unreserve(el.dryml_name)
    end

    
    def template_call(el)
      name = call_name(el)
      merge_name = extract_merge_name!(el)
      options = tag_options(el)
      newlines = tag_newlines(el)
      
      template_procs = compile_template_procs(el)
      
      call = if merge_name
               merge_name = attribute_to_ruby(merge_name, :symbolize => true)
               "merge_and_call_template(:#{name}, #{options}, #{template_procs}, template_procs[#{merge_name}])"
             else
               "#{name}(#{options}, #{template_procs})"
             end

      "<% _output(#{call}) %>"
    end
    
    
    def compile_template_procs(el)
      dryml_exception("content is not allowed directly inside template calls", el) if 
        el.children.find { |e| e.is_a?(REXML::Text) && !e.to_s.blank? }
      
      param_groups = el.elements.group_by { |e| e.name.split('.')[0] }
      
      param_options = param_groups.map do |group_name, tags| 
        if tags.length == 1 and (e = tags.first) and e.name !~ /\./
          merge_name = extract_merge_name!(e)
          if merge_name
            if template_call?(e)
              ":#{e.name} => merge_template_parameter_procs(#{template_proc(e)}, template_procs[:#{merge_name}])"
            else
              ":#{e.name} => merge_option_procs(#{template_proc(e)}, template_procs[:#{merge_name}])"
            end
          else
            ":#{e.name} => #{template_proc(e)}"
          end
        else
          merge_param, modifiers = tags.partition{ |e| e.name == group_name }
          dryml_exception("duplicate template parameter: #{group_name}", el) if merge_param.length > 1
          merge_param = merge_param.first # there's zero or one
          
          ":#{group_name} => #{template_proc(merge_param, modifiers)}"
        end
      end
      "{" + param_options.join(', ') + "}"
    end
    
    
    def template_proc(el, modifiers=[])
      options = modifiers.map do |e|
        mod = e.name.split('.')[1]
        dryml_exception("invalid template parameter modifier: #{e.name}") if 
          !mod.in? %w{before after append prepend replace}

        ":_#{mod} => proc { new_context { %>#{children_to_erb(e)}<% } }"
      end
      
      if el
        options.concat(el.attributes.map { |name, value| ":#{name} => #{attribute_to_ruby(value)}" })
      end
      
      if el && template_call?(el)
        "proc { [{#{options * ', '}}, #{compile_template_procs(el)}] }"
      else
        if el && el.has_end_tag?
          body = children_to_erb(el)
          options << ":tagbody => proc { new_context { %>#{body}<% } } " 
        end
        "proc { {#{options * ', '}} }"
      end
    end

    
    def tag_call(el)
      name = call_name(el)
      merge_name = extract_merge_name!(el)
      options = tag_options(el)
      newlines = tag_newlines(el)

      call = if merge_name
               merge_name = attribute_to_ruby(merge_name, :symbolize => true)
               "merge_and_call(:#{name}, #{options}, template_procs[#{merge_name}])"
             else
               "#{name}(#{options unless options == '{}'})"
             end
      
      part_name = el.attributes['part']
      if el.children.empty?
        if part_name
          "<span id='#{part_name}'>" + part_element(el, "<%= #{call} %>") + "</span>"
        else
          "<%= #{call} #{newlines}%>"
        end
      else
        children = children_to_erb(el)
        if part_name
          id = el.attributes['id'] || part_name
          "<span id='<%= #{attribute_to_ruby(id)} %>'>" +
            part_element(el, "<% _output(#{call} do %>#{children}<% end) %>") +
            "</span>"
        else
          "<% _output(#{call} do #{newlines}%>#{children}<% end) %>"
        end
      end
    end
    
    
    def tag_options(el)
      attributes = el.attributes
      items = attributes.map {|n,v| ":#{n} => #{attribute_to_ruby(v)}" }

      # if there's a ':' el.name is just the part after the ':'
      items << ":field => \"#{el.name}\"" if el.name != el.expanded_name
      
      options = items.join(", ")
      
      merge_attrs = attributes['merge_attrs']
      if merge_attrs
        extra_options = if merge_attrs == "&true"
                          "options"
                        elsif merge_attrs.starts_with?(CODE_ATTRIBUTE_CHAR)
                          merge_attrs[1..-1]
                        else
                          dryml_exception("invalid merge_attrs", el)
                        end
        "{#{options}}.merge((#{extra_options}) || {})"
      elsif options.empty?
        "{}"
      else
        "{#{options}}"
      end
    end

    def static_tag_to_method_call(el)
      part = el.attributes["part"]
      attrs = el.attributes.map do |n, v|
        next if n.in? %w(merge_attrs part)
        
        val = v.gsub('"', '\"')
        %(:#{n} => "#{val}")
      end
      # If there's a part but no id, the id defaults to the part name
      if part && !el.attributes["id"]
        attrs << ":id => '#{part}'"
      end
      
      # Convert the attributes hash to a call to merge_attrs if
      # there's a merge_attrs attribute
      attrs = if (merge_attrs = el.attributes['merge_attrs'])
                dryml_exception("merge_attrs was given a string", el) unless is_code_attribute?(merge_attrs)
        
                "merge_attrs({#{attrs * ', '}}, " +
                  "((__merge_attrs__ = (#{merge_attrs[1..-1]})) == true ? options : __merge_attrs__))"
              else
                "{" + attrs.join(', ') + "}"
              end
      
      if el.children.empty?
        dryml_exception("part attribute on empty static tag", el) if part
        
        args = ["", attrs].compact.join(', ')
        method = "tag"
        "<%= tag(:#{el.name}, #{attrs} #{tag_newlines(el)})%>"
      else
        if part
          body = part_element(el, children_to_erb(el))
        else
          body = children_to_erb(el)               
        end

        args = [":#{el.name}", body, attrs].compact.join(', ')
        method = "content_tag"
        "<%= tag :#{el.name}, #{attrs}, true #{tag_newlines(el)} %>#{body}</#{el.name}>"
      end
    end
    
    def static_element_to_erb(el)
      if el.attributes["part"] || el.attributes["merge_attrs"]
        static_tag_to_method_call(el)
      else
        start_tag_src = el.start_tag_source.gsub(REXML::CData::START, "").gsub(REXML::CData::STOP, "")
        
        # Allow #{...} as an alternate to <%= ... %>
        start_tag_src.sub!(/=\s*('.*?'|".*?")/) do |s|
          s.gsub(/#\{(.*?)\}/, '<%= \1 %>')
        end

        if el.has_end_tag?
          start_tag_src + children_to_erb(el) + "</#{el.name}>"
        else
          start_tag_src
        end
      end
    end

    def attribute_to_ruby(attr, options={})
      dryml_exception('erb scriptlet in attribute of defined tag (use #{ ... } instead)') if
        attr.is_a?(String) && attr.index("[![HOBO-ERB")

      if options[:symbolize] && attr =~ /^[a-zA-Z_][^a-zA-Z0-9_]*[\?!]?/
        ":#{attr}"
      else
        res = if attr.nil?
                "nil"
              elsif is_code_attribute?(attr)
                "(#{attr[1..-1]})"
              else
                if attr !~ /"/
                  '"' + attr + '"'
                elsif attr !~ /'/
                  "'#{attr}'"
                else
                  dryml_exception("invalid quote(s) in attribute value")
                end
                #attr.starts_with?("++") ? "attr_extension(#{str})" : str
              end 
        options[:symbolize] ? (res + ".to_sym") : res
      end
    end

    def find_ancestor(el)
      e = el.parent
      until e.is_a? REXML::Document
        return e if yield(e)
        e = e.parent
      end
      return nil
    end

    def require_toplevel(el, message=nil)
      message ||= "can only be at the top level"
      dryml_exception("<#{el.name}> #{message}", el) if el.parent != @doc.root
    end

    def require_attribute(el, name, rx=nil, optional=false)
      val = el.attributes[name]
      if val
        dryml_exception("invalid #{name}=\"#{val}\" attribute on <#{el.name}>", el) unless rx && val =~ rx
      else
        dryml_exception("missing #{name} attribute on <#{el.name}>", el) unless optional
      end
    end

    def dryml_exception(message, el=nil)
      el ||= @last_element
      raise DrymlException.new(message, template_path, element_line_num(el))
    end

    def element_line_num(el)
      offset = el.source_offset
      line_no = @xmlsrc[0..offset].count("\n") + 1
    end

    def tag_newlines(el)
      src = el.start_tag_source
      "\n" * src.count("\n")
    end

    def is_code_attribute?(attr_value)
      attr_value.starts_with?(CODE_ATTRIBUTE_CHAR)
    end

    def logger
      ActionController::Base.logger rescue nil
    end

  end

end
