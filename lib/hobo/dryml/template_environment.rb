module Hobo::Dryml

  class TemplateEnvironment
    
    class << self
      def inherited(subclass)
        subclass.compiled_local_names = []
      end
      attr_accessor :load_time, :compiled_local_names
      
      # --- Local Tags --- #
      
      def start_redefine_block(method_names)
        @_preserved_methods_for_redefine ||= []
        @_redef_impl_names ||= []
        
        methods = method_names.map_hash {|m| instance_method(m) }
        @_preserved_methods_for_redefine.push(methods)
        @_redef_impl_names.push []
      end
      
      
      def end_redefine_block
        methods = @_preserved_methods_for_redefine.pop
        methods.each_pair {|name, method| define_method(name, method) }
        to_remove = @_redef_impl_names.pop
        to_remove.each {|m| remove_method(m) }
      end
      
      
      def redefine_nesting
        @_preserved_methods_for_redefine.length
      end
      
      
      def redefine_tag(name, proc)
        impl_name = "#{name}_redefined_#{redefine_nesting}"
        define_method(impl_name, proc)
        class_eval "def #{name}(options={}, template_parameters={}, &b); " +
          "#{impl_name}(options, template_parameters, b); end"
        @_redef_impl_names.push(impl_name)
      end
      
      # --- end local tags --- #
      
      
      def _register_tag_attrs(tag_name, attrs)
        @tag_attrs ||= {}
        @tag_attrs[tag_name] = attrs
      end
      
      attr_reader :tag_attrs
      
    end

    for mod in ActionView::Helpers.constants.grep(/Helper$/).map {|m| ActionView::Helpers.const_get(m)}
      include mod
    end

    def initialize(view_name=nil, view=nil)
      unless view_name.nil? && view.nil?
        @view = view
        @_view_name = view_name
        @_erb_binding = binding
        @_part_contexts = {}

        # Make sure the "assigns" from the controller are available (instance variables)
        if view
          view.assigns.each do |key, value|
            instance_variable_set("@#{key}", value)
          end

          # copy view instance variables over
          view.instance_variables.each do |iv|
            instance_variable_set(iv, view.instance_variable_get(iv))
          end
        end
      end
    end

    attr_accessor 

    for attr in [:erb_binding, :part_contexts, :view_name,
                 :this, :this_parent, :this_field, :this_type,
                 :form_field_path, :form_this, :form_field_names]
      class_eval "def #{attr}; @_#{attr}; end"
    end
    
    
    def attrs_for(name)
      self.class.tag_attrs[name]
    end
    
    
    def merge_attrs(options, klass=nil)
      options ||= {}
      if klass
        options = add_classes(options.symbolize_keys, [klass])
      end
      options.map do |n,v|
        if v == true
          n
        else
          v = v.to_s
          val = v.include?('"') ? "'" + v + "'" : '"' + v + '"'
          "#{n}=#{val}"
        end
      end.join(' ')
    end


    def attr_extension(s)
      AttributeExtensionString.new(s)
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
          @_part_contexts[dom_id] = [part_id, part_context_model_id]
          res = send("#{part_id}_part")
        end
      else
        new_context do
          @_part_contexts[dom_id] = [part_id, part_context_model_id]
          res = send("#{part_id}_part")
        end
      end
      res
    end
    

    def _erbout
      @_erb_output
    end
    
    
    def _output(s)
      @_erb_output.concat(s)
    end


    def new_context
      ctx = [ @_erb_output,
              @_this, @_this_parent, @_this_field, @_this_type,
              @_form_field_path]
      @_erb_output = ""
      res = yield
      @_erb_output, @_this, @_this_parent, @_this_field, @_this_type,
          @_form_field_path = ctx
      res.to_s
    end


    def new_object_context(new_this)
      new_context do
        @_this_parent,@_this_field,@_this_type = if new_this.respond_to?(:proxy_reflection)
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
        

        @_this, @_this_parent, @_this_field, @_this_type = obj, parent, field, type
        @_form_field_path += path if @_form_field_path
        yield
      end
    end


    def _tag_context(options, tagbody_proc)
      tagbody = tagbody_proc && proc do |*args|
        res = ''
        
        block_options = args.length > 0 && args.first
        block_with = block_options && block_options[:with]
        if block_options && block_options.has_key?(:field)
          new_field_context(block_options[:field], block_with) { res = tagbody_proc.call }
        elsif block_options && block_options.has_key?(:with)
          new_object_context(block_with) { res = tagbody_proc.call }
        else
          new_context { res = tagbody_proc.call }
        end
        res
      end
      
      with = options[:with] == "page" ? @this : options[:with]
      
      if options.has_key?(:field)
        new_field_context(options[:field], with) { yield tagbody }
      elsif options.has_key?(:with)
        new_object_context(with) { yield tagbody }
      else
        new_context { yield tagbody }
      end
    end


    def with_form_context
      @_form_this = this
      @_form_field_path = []
      @_form_field_names = []
      res = yield
      field_names = @_form_field_names
      @_form_this = @_form_field_path = @_form_field_names = nil
      [res, field_names]
    end
    
    
    def register_form_field(name)
      @_form_field_names << name
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
      #ensure with and field are not in options
      options.delete(:with)
      options.delete(:field)
      
      # positional arguments never appear in the options hash
      stripped_options = {}.update(options)
      attrs.each {|a| stripped_options.delete(a.to_sym) }
      
      # Return attrs declared as local variables (attrs="...")
      call_procs_options = Hobo::LazyHash.new(options)
      attrs.map {|a| call_procs_options[a.to_sym]} + [lazy_hash(stripped_options)]
    end
    
    
    def merge_and_call(name, options, overriding_proc, &b)
      if overriding_proc
        overriding_options = overriding_proc.call
        tagbody = overriding_options.delete(:tagbody)
        options = options.update(overriding_options)
      end      
      
      if name.to_s.in?(Hobo.static_tags)
        if tagbody || b
          body = if tagbody
                   tagbody.call
                 elsif b
                   new_context(&b)
                 end
          content_tag(name, body, options)
        else
          tag(name, options)
        end
      else
        send(name, options, &(tagbody || b))
      end
    end
    
    
    def merge_and_call_template(name, options, template_procs, overriding_proc)
      if overriding_proc
        overriding_options, overriding_template_procs = overriding_proc.call
        options = options.merge(overriding_options)
        template_procs = template_procs.merge(overriding_template_procs)
      end      
      
      send(name, options, template_procs)
    end
    
    # Takes two procs that each returh hashes and returns a single
    # proc that calls these in turn and merges the results into a
    # single hash
    def merge_option_procs(general_proc, overriding_proc)
      proc { general_param.call.merge(overriding_param.call) }
    end
    
    # Same as merge_option_procs, except these procs return a pair of
    # hashes rather than a single hash. The first hash is the tag
    # attributes (options), the second is a hash of procs -- the
    # template parameters.
    def merge_template_parameter_procs(general_proc, overriding_proc)
      proc do
        general_options, general_template_procs = general_proc.call
        overriding_options, overriding_template_procs = overriding_proc.call
        [general_options.merge(overriding_options), general_template_procs.merge(overriding_template_procs)]
      end
    end
    
    
    def DELETE_ME_call_replaceable_tag(name, options, external_param, &b)
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
    
    
    def DELETE_ME_call_replaceable_content_tag(name, options, external_param, &b)
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
        
    
    def lazy_hash(hash)
      Hobo::LazyHash.new(hash)
    end


    def render_tag(tag_name, options)
      (send(tag_name, options) + part_contexts_js).strip
    end
    
    
    def method_missing(name, *args, &b)
      @view.send(name, *args, &b)
    end
    

  end
  

end
