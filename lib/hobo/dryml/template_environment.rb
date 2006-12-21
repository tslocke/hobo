module Hobo::Dryml

  class TemplateEnvironment

    extend TagModule # include as class methods

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

    attr_reader :this, :this_parent, :this_field, :this_type, :form_field_path, :form_this


    def this_field_dom_id
      Hobo.dom_id(this_parent, this_field)
    end


    def part_context_model_id
      if this_parent and this_field
        this_field_dom_id
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
      ctx = @output, @this, @this_parent, @this_field, @this_type, @form_field_path
      @output = ""
      yield
      output = @output
      @output, @this, @this_parent, @this_field, @this_type, @form_field_path = ctx
      output
    end


    def new_object_context(new_this)
      new_context do
        @this_parent, @this_field, @this_type = if new_this.respond_to?(:proxy_reflection)
                                                  refl = new_this.proxy_reflection
                                                  [new_this.proxy_owner, refl.name, refl]
                                                else
                                                  [nil, nil, (this.class if this.is_a?(ActiveRecord::Base))]
                                                end
        @this = new_this
        yield
      end
    end


    def new_field_context(field_path)
      new_context do
        path = if field_path.is_a? Array
                 field_path
               elsif field_path.is_a? String
                 field_path.split('.')
               else
                 [field_path]
               end

        obj = this
        for field in path
          parent = obj
          obj = if parent.is_a? Array
                  obj = parent[field.to_i]
                else
                  parent.send(field)
                end
        end

        type = if parent.class.respond_to?(:field_type) and col_type = parent.class.field_type(field)
                 col_type
               else
                 obj.class
               end

        @this, @this_parent, @this_field, @this_type = obj, parent, field, type
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

      if options.has_key?(:obj)
        new_object_context(options[:obj]) { yield tagbody }
      elsif options.has_key?(:attr)
        new_field_context(options[:attr]) { yield tagbody }
      else
        new_context { yield tagbody }
      end
    end


    def with_form_context
      @form_this = this
      @form_field_path = []
      res = yield
      @form_this = nil
      @form_field_path = nil
      res
    end


    def _part_contexts_js(initialise)
      return "" if part_contexts.empty?

      assigns = part_contexts.map do |dom_id, p|
        part_id, model_id = p
        "hoboParts.#{dom_id} = ['#{part_id}', '#{model_id}']\n"
      end

      "<script>\n" + (if initialise then "var hoboParts = {}\n" end) + assigns.join + "</script>\n"
    end


    def _tag_locals(options, attrs)
      options.symbolize_keys!
      #ensure obj and attr are not in options
      options.delete(:obj)
      options.delete(:attr)

      # positional arguments never appear in the options hash
      stripped_options = {}.update(options)
      attrs.each {|a| stripped_options.delete(a.to_sym) }
      attrs.map {|a| options[a.to_sym]} + [stripped_options]
    end


    def render_tag(tag_name, options)
      (send(tag_name, options) + _part_contexts_js(true)).strip
    end


    def method_missing(name, *args)
      @view.send(name, *args)
    end

  end

end
