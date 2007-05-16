require 'rexml/document'

module Hobo::Dryml

  class Template

    DRYML_NAME = "[a-zA-Z_][a-zA-Z0-9_]*"

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
      @environment.send(:include, Hobo::PredicateDispatch)

      @template_path = template_path.sub(/^#{Regexp.escape(RAILS_ROOT)}/, "")

      @builder = Template.build_cache[@template_path] || DRYMLBuilder.new(@template_path)
      @builder.set_environment(environment)

      @last_element = nil
    end

    attr_reader :tags, :template_path
    
    def compile(local_names=[], auto_taglibs=true)
      now = Time.now

      unless @template_path == EMPTY_PAGE
        filename = RAILS_ROOT + (@template_path.starts_with?("/") ? @template_path : "/" + @template_path)
        mtime = File.stat(filename).mtime
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
      src = ERB.new(erb_src, nil, ActionView::Base.erb_trim_mode).src[("_erbout = '';").length..-1]
      @builder.add_build_instruction(:render_page, :src => src, :line_num => 1)
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
      @doc = REXML::Document.new(RexSource.new(@xmlsrc))
      
      restore_erb_scriptlets(children_to_erb(@doc.root))
    end

    
    def restore_erb_scriptlets(src)
      src.gsub(/\[!\[HOBO-ERB(\d+)\s*\]!\]/m) {|s| "<%#{@scriptlets[$1.to_i]}%>" }
    end
 
    
    def erb_process(src)
      # Strip off "_erbout = ''" from the beginning and "; _erbout"
      # from the end, because we do things differently around
      # here. (_erbout is defined as a method)
      ERB.new(restore_erb_scriptlets(src)).src["_erbout = '';".length..-("; _erbout".length)]
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
      dryml_exception("badly placed parameter tag <#{el.name}>", el) if
        el.name.starts_with?(":")

      @last_element = el
      case el.name

      when "taglib"
        taglib_element(el)
        # return nothing - the import has no presence in the erb source
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
        
      when "redefine"
        redefine_element(el)

      else
        if el.name.not_in?(Hobo.static_tags) or
            el.attributes['replace_option'] or el.attributes['content_option']
          tag_call(el)
        else
          html_element_to_erb(el)
        end
      end
    end


    def taglib_element(el)
      require_toplevel(el)
      require_attribute(el, "as", /^#{DRYML_NAME}$/, true)
      if el.attributes["src"]
        @builder.add_build_instruction(:taglib, 
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


    def def_element(el)
      redefine = el.parent.name == "redefine"
      
      require_toplevel(el, "must be at the top-level or inside a <redefine>") unless redefine
      require_attribute(el, "tag", /^#{DRYML_NAME}$/)
      require_attribute(el, "attrs", /^\s*#{DRYML_NAME}(\s*,\s*#{DRYML_NAME})*\s*$/, true)
      require_attribute(el, "alias_of", /^#{DRYML_NAME}$/, true)
      require_attribute(el, "alias_current", /^#{DRYML_NAME}$/, true)

      unsafe_name = el.attributes["tag"]
      name = Hobo::Dryml.unreserve(unsafe_name)

      alias_of = el.attributes['alias_of']
      alias_current = el.attributes['alias_current']

      dryml_exception("def cannot have both alias_of and alias_current", el) if alias_of && alias_current
      dryml_exception("def with alias_of must be empty", el) if alias_of and el.size > 0
      
      dryml_exception("redefined methods cannot have predicates", el) if redefine && el.attributes["if"]
                      
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
      
      # While processing the children of this def, @def_name contains
      # the names of all nested defs join with '_'. It's used to
      # disambiguate the +tagbody+ local variables.
      res = if alias_of
              "#{re_alias}<% #{tag_newlines(el)} %>"
            else
              tag_method(name, el, re_alias, redefine)
            end
    end
    
    
    def tag_method(name, el, re_alias, redefine)
      attrspec = el.attributes["attrs"]
      attr_names = attrspec ? attrspec.split(/\s*,\s*/) : []

      invalids = attr_names & %w{obj attr this}
      dryml_exception("invalid attrs in def: #{invalids * ', '}", el) unless invalids.empty?

      method_body = tag_method_body(el, attr_names.omap{to_sym})
      logger.debug(restore_erb_scriptlets(method_body)) if el.attributes["hobo_debug_source"]
      
      res = if redefine
              re_alias + "<% self.class.redefine_tag(:#{name}, proc {|__options__, __block__| " +
                ("#{@def_name}_tagbody = tagbody; " if @def_name).to_s + "__res__ = #{method_body} " +
                ("; tagbody = #{@def_name}_tagbody; __res__; " if @def_name).to_s + "}); %>"
            else
              pred = el.attributes["if"]
              pred = pred[1..-1] if pred && pred.starts_with?('#')

              @builder.add_build_instruction(:def,
                                             :name => name,
                                             :method_body => erb_process("<% #{method_body} %>"),
                                             :line_num => element_line_num(el),
                                             :predicate => pred)
              # keep line numbers matching up
              "<% #{"\n" * method_body.count("\n")} %>"
            end
      res
    end


    def tag_method_body(el, attrs)
      inner_tags = find_inner_tags(el)

      # A statement to assign values to local variables named after the tag's attrs.
      locals_lhs = attrs.map{|a| "#{Hobo::Dryml.unreserve(a)}, "}.join + " = " if attrs.any?
      setup_locals = "#{locals_lhs}_tag_locals(__options__, #{attrs.inspect}, #{inner_tags.inspect})"

      start = "_tag_context(__options__, __block__) do |tagbody| #{setup_locals}"
      
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
    
    
    def find_inner_tags(el)
      el.map do |e|
        if e.is_a?(REXML::Element)
          name = e.attributes["content_option"] || e.attributes["replace_option"]
          [(name if name && !is_code_attribute?(name))] + find_inner_tags(e)
        else
          []
        end
      end.flatten.compact
    end


    def tagbody_element(el)
      dryml_exception("tagbody can only appear inside a <def>", el) unless
        find_ancestor(el) {|e| e.name == 'def'}
      dryml_exception("tagbody cannot appear inside a part", el) if
        find_ancestor(el) {|e| e.attributes['part_id']}
      tagbody_call(el)
    end


    def tagbody_call(el)
      options = []
      obj = el.attributes['obj']
      attr = el.attributes['attr']
      options << ":obj => #{attribute_to_ruby(obj)}" if obj
      options << ":attr => #{attribute_to_ruby(attr)}" if attr
      else_ = attribute_to_ruby(el.attributes['else'])
      "<%= tagbody ? tagbody.call({ #{options * ', '} }) : #{else_} %>"
    end


    def part_element(el, content)
      require_attribute(el, "part_id", /^#{DRYML_NAME}$/)
      part_name  = el.attributes['part_id']
      dom_id = el.attributes['id'] || part_name
      
      part_src = "<% def #{part_name}_part #{tag_newlines(el)}; new_context do %>" +
        content +
        "<% end; end %>"
      @builder.add_part(part_name, erb_process(part_src), element_line_num(el))

      newlines = "\n" * part_src.count("\n")
      res = "<%= call_part(#{attribute_to_ruby(dom_id)}, :#{part_name}) #{newlines} %>"
      res
    end

    
    def tag_call(el)
      require_attribute(el, "content_option", /#{DRYML_NAME}/, true)
      require_attribute(el, "replace_option", /#{DRYML_NAME}/, true)
      
      # find out if it's empty before removing any <:param_tags>
      empty_el = el.size == 0

      # gather <:param_tags>, and remove them from the dom
      compiled_param_tags = compile_parameter_tags(el)
        
      name = Hobo::Dryml.unreserve(el.name)
      options = tag_options(el, compiled_param_tags)
      newlines = tag_newlines(el)
      replace_option = el.attributes["replace_option"]
      content_option = el.attributes["content_option"]
      dryml_exception("both replace_option and content_option given") if replace_option && content_option
      call = if replace_option
               replace_option = attribute_to_ruby(replace_option)
               "call_replaceable_tag(:#{name}, #{options}, inner_tag_options[#{replace_option}.to_sym])"
             elsif content_option
               content_option = attribute_to_ruby(content_option)
               "call_replaceable_content_tag(:#{name}, #{options}, inner_tag_options[#{content_option}.to_sym])"
             else
               "#{name}(#{options})"
             end

      part_id = el.attributes['part_id']
      if empty_el
        if part_id
          "<span id='#{part_id}'>" + part_element(el, "<%= #{call} %>") + "</span>"
        else
          "<%= #{call} #{newlines}%>"
        end
      else
        children = children_to_erb(el)
        if part_id
          id = el.attributes['id'] || part_id
          "<span id='<%= #{attribute_to_ruby(id)} %>'>" +
            part_element(el, "<% _erbout.concat(#{call} do %>#{children}<% end) %>") +
            "</span>"
        else
          "<% _erbout.concat(#{call} do #{newlines}%>#{children}<% end) %>"
        end
      end
    end
    
    
    def compile_parameter_tags(el)
      # The implementation of parameter tags is greatly complicated
      # by the need to maintain line-number parity between the dryml source
      # and generated erb source
      
      last = el.children.reverse.ofind{is_a?(REXML::Element) && name.starts_with?(":")}
      return "" if last.nil?
      param_section = el.children[0..el.index(last)]
      
      dryml_exception("invalid content before parameter tag", el) unless param_section.all? do |e|
        (e.is_a?(REXML::Element) && e.name.starts_with?(":")) || 
          (e.is_a?(REXML::Text) && e.to_s.blank?) ||
          e.is_a?(REXML::Comment) 
      end
      
      last = param_section.last
      compiled = param_section.map do |e|
        # REXML Bug - don't use el.remove (also removes other children that are == )
        el.delete_at(el.index(e))
        case e
        when REXML::Element
          # Multiple param tags with the same name are allowed - they
          # become an array passed to the tag
          array_index = begin
                          # If there are other param-tags with this
                          # name, the index of this one, else nil
                          same_name_params = param_section.select {|x| x.is_a?(REXML::Element) and x.name == e.name}
                          same_name_params.length > 1 && same_name_params.index(e)
                        end
          
          param_name = attr_name_to_option_key(e.name[1..-1], array_index)
          
          dryml_exception("duplicate attribute/parameter-tag #{param}", el) if
            param_name.in?(el.attributes.keys)
          
          param_value = 
            if e.has_attributes?
              pairs = e.attributes.map do |n,v|
              "#{attr_name_to_option_key(n)} => " + "proc { #{attribute_to_ruby(v)} }"
              end
              # If there is content too, that goes in the hash under the key :content
              if e.size > 0
                pairs << "#{tag_newlines(el)}:content => (proc { new_context { %>#{children_to_erb(e)}<%; } })"
              end
              "{" + pairs.join(",") + "}"
            elsif e.size > 0
              "#{tag_newlines(el)}(proc { new_context { %>#{children_to_erb(e)}<%; }})"
            else
              "''"
            end
          pair = "#{param_name} => #{param_value}"
          pair << ", " unless e == last
          pair
          
        when REXML::Text
          e.to_s
          
        when REXML::Comment
          REXML::Comment::START + node.to_s + REXML::Comment::STOP
          
        end
      end
      
      compiled.join
    end
      
    
    def attr_name_to_option_key(name, array_index=nil)
      parts = name.split(".").map { |p| ":#{p}" }
      parts << array_index if array_index
      if parts.length == 1
        parts.first
      else
        "[" + parts.join(', ') + "]"
      end
    end
    
    
    def tag_options(el, param_tags_compiled)
      attributes = el.attributes

      options = attributes.map do |n,v|
        param_name = attr_name_to_option_key(n)
        param_value = attribute_to_ruby(v)
        "#{param_name} => #{param_value}"
      end
      
      options << param_tags_compiled unless param_tags_compiled.blank?
      all = options.join(', ')
      
      xattrs = attributes['xattrs']
      if xattrs
        extra_options = if xattrs.blank?
                          "options"
                        elsif xattrs.starts_with?("#")
                          xattrs[1..-1]
                        else
                          dryml_exception("invalid xattrs", el)
                        end
        "{#{all}}.merge((#{extra_options}) || {})"
      else
        "{#{all}}"
      end
    end

    
    def html_element_to_erb(el)
      start_tag_src = el.instance_variable_get("@start_tag_source").
        gsub(REXML::CData::START, "").gsub(REXML::CData::STOP, "")

      xattrs = el.attributes["xattrs"]
      if xattrs
        attr_args = if xattrs.starts_with?('#')
                      xattrs[1..-1]
                    elsif xattrs.blank?
                      "options"
                    else
                      dryml_exception("invalid xattrs", el)
                    end
        class_attr = el.attributes["class"]
        if class_attr
          raise HoboError.new("invalid class attribute with xattrs: '#{class_attr}'") if
            class_attr =~ /'|\[!\[HOBO-ERB/

          attr_args.concat(", '#{class_attr}'")
          start_tag_src.sub!(/\s*class\s*=\s*('[^']*?'|"[^"]*?")/, "")
        end
        start_tag_src.sub!(/\s*xattrs\s*=\s*('[^']*?'|"[^"]*?")/, " <%= xattrs(#{attr_args}) %>")
      end
      
      # Allow #{...} as an alternate to <%= ... %>
      start_tag_src.sub!(/=\s*('[^']*?'|"[^"]*?")/) do |s|
        s.gsub(/#\{([^}]*)\}/, '<%= \1 %>')
      end

      if start_tag_src.ends_with?("/>")
        start_tag_src
      else
        if el.attributes['part_id']
          body = part_element(el, children_to_erb(el))
          if el.attributes["id"]
            # remove part_id, and eval the id attribute with an erb scriptlet
            start_tag_src.sub!(/\s*part_id\s*=\s*('[^']*?'|"[^"]*?")/, "")
            id_expr = attribute_to_ruby(el.attributes['id'])
            start_tag_src.sub!(/id\s*=\s*('[^']*?'|"[^"]*?")/, "id='<%= #{id_expr} %>'")
          else
            # rename part_id to id
            start_tag_src.sub!(/part_id\s*=\s*('[^']*?'|"[^"]*?")/, "id=\\1")
          end
          dryml_exception("multiple part ids", el) if start_tag_src.index("part_id=")


          start_tag_src + body + "</#{el.name}>"
        else
          start_tag_src + children_to_erb(el) + "</#{el.name}>"
        end
      end
    end

    def attribute_to_ruby(attr)
      dryml_exception('erb scriptlet in attribute of defined tag (use #{ ... } instead)') if attr && attr.index("[![HOBO-ERB")
      if attr.nil?
        "nil"
      elsif is_code_attribute?(attr)
        "(#{attr[1..-1]})"
      else
        str = if not attr =~ /"/
                '"' + attr + '"'
              elsif not attr =~ /'/
                "'#{attr}'"
              else
                dryml_exception("invalid quote(s) in attribute value")
              end
        attr.starts_with?("++") ? "attr_extension(#{str})" : str
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
      offset = el.instance_variable_get("@source_offset")
      line_no = @xmlsrc[0..offset].count("\n") + 1
    end

    def tag_newlines(el)
      src = el.instance_variable_get("@start_tag_source")
      "\n" * src.count("\n")
    end

    def is_code_attribute?(attr_value)
      attr_value.starts_with?("#")
    end

    def logger
      ActionController::Base.logger rescue nil
    end

  end

end
