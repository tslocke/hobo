module Hobo::Dryml

  class TemplateEnvironment

    class << self
      def inherited(subclass)
        subclass.compiled_local_names = []
      end
      attr_accessor :load_time, :compiled_local_names
    end

    for mod in ActionView::Helpers.constants.grep(/Helper$/).map {|m| ActionView::Helpers.const_get(m)}
      include mod
    end

    def initialize(view_name, view)
      @view = view
      @view_name = view_name
      @erb_binding = binding
      @part_contexts = {}
      @stack = [nil]

      # Make sure the "assigns" from the controller are available (instance variables)
      if view
        view.assigns.each do |key, value|
          instance_variable_set("@#{key}", value)
        end

        # copy view instance variables over
        view.instance_variables.each do |iv|
          instance_variable_set(iv, @view.instance_variable_get(iv))
        end
      end
    end

    attr_accessor :erb_binding, :part_contexts, :view_name

    attr_reader :this_parent, :this_field, :this_type, :form_field_path, :form_this, :form_field_names
    
    def this; @_this; end
    
    def attr_extension(s)
      Dryml::AttributeExtensionString.new(s)
    end
    
    
    def this_field_dom_id
      Hobo.dom_id(this_parent, this_field)
    end


    def part_context_model_id
      if this_parent and this_parent.is_a?(ActiveRecord::Base) and this_field
        this_field_dom_id
      elsif this.respond_to?(:typed_id)
        this.typed_id
      elsif this.is_a?(Array) and !this.respond_to?(:proxy_reflection)
        "nil"
      else
        Hobo.dom_id(this)
      end
    end


    def call_part(dom_id, part_id, part_this=nil)
      res = ''
      if part_this
        new_object_context(part_this) do
          @part_contexts[dom_id] = [part_id, part_context_model_id]
          res = send("#{part_id}_part")
        end
      else
        new_context do
          @part_contexts[dom_id] = [part_id, part_context_model_id]
          res = send("#{part_id}_part")
        end
      end
      res
    end


    def _erbout
      @output
    end


    def new_context
      ctx = @output, @_this, @this_parent, @this_field, @this_type, @form_field_path
      @output = ""
      res = yield
      @output, @_this, @this_parent, @this_field, @this_type, @form_field_path = ctx
      res.to_s
    end


    def new_object_context(new_this)
      new_context do
        @this_parent,@this_field,@this_type = if new_this.respond_to?(:proxy_reflection)
                                                refl = new_this.proxy_reflection
                                                [new_this.proxy_owner, refl.name, refl]
                                              else
                                                [nil, nil, new_this.class]
                                              end
        @_this = new_this
        yield
      end
    end


    def new_field_context(field_path, tag_this=nil)
      new_context do
        path = if field_path.is_a? Array
                 field_path
               elsif field_path.is_a? String
                 field_path.split('.')
               else
                 [field_path]
               end

        obj = tag_this || this
        for field in path
          parent = obj
          obj = Hobo.get_field(parent, field)
        end

        type = if (obj.nil? or obj.respond_to?(:proxy_reflection)) and
                   parent.class.respond_to?(:field_type) and field_type = parent.class.field_type(field)
                 field_type
               else
                 obj.class
               end
        

        @_this, @this_parent, @this_field, @this_type = obj, parent, field, type
        @form_field_path += path if @form_field_path
        yield
      end
    end


    def _tag_context(options, tagbody_proc)
      tagbody = tagbody_proc && proc do |*args|
        res = ''
        block_options = args.length > 0 && args.first
        if block_options and block_options.has_key?(:obj)
          new_object_context(block_options[:obj]) { res = tagbody_proc.call }
        elsif block_options and block_options.has_key?(:attr)
          new_field_context(block_options[:attr]) { res = tagbody_proc.call }
        else
          new_context { res = tagbody_proc.call }
        end
        res
      end
      
      obj = options[:obj] == "page" ? @this : options[:obj]

      if options.has_key?(:attr)
        new_field_context(options[:attr], obj) { yield tagbody }
      elsif options.has_key?(:obj)
        new_object_context(obj) { yield tagbody }
      else
        new_context { yield tagbody }
      end
    end


    def with_form_context
      @form_this = this
      @form_field_path = []
      @form_field_names = []
      res = yield
      field_names = @form_field_names
      @form_this = @form_field_path = @form_field_names = nil
      [res, field_names]
    end
    
    
    def register_form_field(name)
      @form_field_names << name
    end


    def part_contexts_js
      return "" if part_contexts.empty?

      assigns = part_contexts.map do |dom_id, p|
        part_id, model_id = p
        "hoboParts.#{dom_id} = ['#{part_id}', '#{model_id}']\n"
      end

      "<script>\nvar hoboParts = {}\n" + assigns.join + "</script>\n"
    end


    def _tag_locals(options, attrs)
      options = Hobo::Dryml.hashify_options(options)
      options.symbolize_keys!
      #ensure obj and attr are not in options
      options.delete(:obj)
      options.delete(:attr)

      # positional arguments never appear in the options hash
      stripped_options = {}.update(options)
      attrs.each {|a| stripped_options.delete(a.to_sym) }
      attrs.map {|a| options[a.to_sym]} + [stripped_options]
    end
    
    
    def call_replaceable_tag(name, options, external_param, &b)
      options.delete(:replace_option)
      
      if external_param.is_a? Hash
        before = external_param.delete(:before_content)
        after = external_param.delete(:after_content)
        top = external_param.delete(:top_content)
        bottom = external_param.delete(:bottom_content)
        content = external_param.delete(:content)
        options = Hobo::Dryml.merge_tag_options(options, external_param)
      elsif !external_param.nil?
        return external_param.to_s
      end

      tag = if respond_to?(name)
              body = if content
                       proc { content }
                     elsif b  && (top || bottom)
                       proc { top.to_s + b.call + bottom.to_s }
                     else
                       b
                     end
              send(name, options, &body)
            else
              body = if content
                       content
                     elsif b
                       top.to_s + new_context { b.call } + bottom.to_s
                     else
                       top.to_s + bottom.to_s
                     end
              content_tag(name, body, options)
            end
      before.to_s + tag.to_s + after.to_s
    end
    
    
    def call_replaceable_content_tag(name, options, external_param, &b)
      options.delete(:content_option)
      
      if external_param.is_a? Hash
        content = external_param.delete(:content)
        top     = external_param.delete(:top_content)
        bottom  = external_param.delete(:bottom_content)
        external_param.delete(:before_content)
        external_param.delete(:after_content)
        options = Hobo::Dryml.merge_tag_options(options, external_param)
      elsif !external_param.nil?
        content = external_param.to_s
      end
      
      # If there's no body, and no content provided externally, remove
      # the tag altogether
      return if b.nil? and content.nil?

      tag = if respond_to?(name)
              body = if content
                       proc { content }
                     elsif b  && (top || bottom)
                       proc { top.to_s + b.call + bottom.to_s }
                     else
                       b
                     end
              send(name, options, &body)
            else
              body = if content
                       content
                     elsif b
                       top.to_s + new_context { b.call } + bottom.to_s
                     else
                       top.to_s + bottom.to_s
                     end
              content_tag(name, body, options)
            end
      tag.to_s
    end


    def render_tag(tag_name, options)
      (send(tag_name, options) + part_contexts_js).strip
    end
    
    
    def method_missing(name, *args)
      @view.send(name, *args)
    end
    

  end
  

end
