module Hobo::Dryml

  class TemplateEnvironment
    
    class << self
      def inherited(subclass)
        subclass.compiled_local_names = []
      end
      attr_accessor :load_time, :compiled_local_names
           
      
      def _register_tag_attrs(tag_name, attrs)
        @tag_attrs ||= {}
        @tag_attrs[tag_name] = attrs
      end
     
      
      def tag_attrs
        @tag_attrs ||= {}
      end
      
      alias_method :delayed_alias_method_chain, :alias_method_chain
      
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
        @_scoped_variables = ScopedVariables.new

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
      self.class.tag_attrs[name.to_sym]
    end
    
    
    def add_classes!(attributes, *classes)
      classes = classes.flatten.select{|x|x}.map{|x| x.to_s.dasherize}
      current = attributes[:class]
      attributes[:class] = (current ? current.split + classes : classes).uniq.join(' ')
      attributes
    end


    def add_classes(attributes, *classes)
      add_classes!(HashWithIndifferentAccess.new(attributes), classes)
    end

    
    def merge_attrs(attrs, overriding_attrs)
      return {}.update(attrs) if overriding_attrs.nil?
      attrs = attrs.with_indifferent_access unless attrs.is_a?(HashWithIndifferentAccess)
      classes = overriding_attrs[:class]
      attrs = add_classes(attrs, *classes.split) if classes
      attrs.update(overriding_attrs - [:class])
    end
    
    
    def scope
      @_scoped_variables
    end


    def attr_extension(s)
      AttributeExtensionString.new(s)
    end

    
    def this_field_dom_id
      if this_parent && this_field
        Hobo.dom_id(this_parent, this_field)
      else
        Hobo.dom_id(this)
      end
    end

    
    def context_id
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

    
    def call_part(dom_id, part_name, part_this=nil, *locals)
      res = ''
      if part_this
        new_object_context(part_this) do
          @_part_contexts[dom_id] = PartContext.new(part_name, context_id, locals)
          res = send("#{part_name}_part", *locals)
        end
      else
        new_context do
          @_part_contexts[dom_id] = PartContext.new(part_name, context_id, locals)
          res = send("#{part_name}_part", *locals)
        end
      end
      res
    end
    
    def call_polymorphic_tag(name, *args)
      type = args.first.is_a?(Class) ? args.shift : nil
      attributes, parameters = args
      
      tag = find_polymorphic_tag(name, type)
      if tag != name
        send(tag, attributes, parameters || {})
      else
        nil
      end
    end

    
    def find_polymorphic_tag(name, call_type=nil)
      call_type ||= if this_type.is_a?(ActiveRecord::Reflection::AssociationReflection)
                      # Don't blow up with non-existent polymorphic types
                      return name if this_type.options[:polymorphic] && !Object.const_defined?(this_type.class_name)
                      this_type.klass
                    elsif this_type <= Array
                      this.member_class
                    else
                      this_type
                    end
      
      call_type = TrueClass if call_type == FalseClass

      while true
        if call_type == ActiveRecord::Base || call_type == Object
          return name
        elsif respond_to?(poly_name = "#{name}__for_#{call_type.name.to_s.underscore.gsub('/', '__')}")
          return poly_name
        else
          call_type = call_type.superclass
        end
      end
    end
    
    
    def repeat_attribute(array, &b)
      res = array.map { |x| new_object_context(x, &b) }.join
      Hobo::Dryml.last_if = !array.empty?
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
      @_erb_output, @_this, @_this_parent, @_this_field, @_this_type, @_form_field_path = ctx
      res.to_s
    end


    def new_object_context(new_this)
      new_context do
        @_this_parent,@_this_field,@_this_type = if new_this.respond_to?(:proxy_reflection)
                                                   refl = new_this.proxy_reflection
                                                   [new_this.proxy_owner, refl.name, refl]
                                                 else
                                                   # In dryml, TrueClass is the 'boolean' class
                                                   t = new_this.class == FalseClass ? TrueClass : new_this.class
                                                   [nil, nil, t]
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
        parent, field, obj = Hobo.get_field_path(tag_this || this, path)

        type = if parent.class.respond_to?(:field_type) && field_type = parent.class.field_type(field)
                 field_type
               elsif obj == false
                 # In dryml, TrueClass is the 'boolean' class
                 TrueClass
               else
                 obj.class
               end
        
        @_this, @_this_parent, @_this_field, @_this_type = obj, parent, field, type
        @_form_field_path += path if @_form_field_path
        yield
      end
    end


    def _tag_context(attributes)
      with = attributes[:with] == "page" ? @this : attributes[:with]
      
      if attributes.has_key?(:field)
        new_field_context(attributes[:field], with) { yield }
      elsif attributes.has_key?(:with)
        new_object_context(with) { yield }
      else
        new_context { yield }
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


    def _tag_locals(attributes, locals)
      attributes.symbolize_keys!
      #ensure with and field are not in attributes
      attributes.delete(:with)
      attributes.delete(:field)
      
      # declared attributes don't appear in the attributes hash
      stripped_attributes = HashWithIndifferentAccess.new.update(attributes)
      locals.each {|a| stripped_attributes.delete(a.to_sym) }
      
      # Return locals declared as local variables (attrs="...")
      locals.map {|a| attributes[a.to_sym]} + [stripped_attributes]
    end
    
    
    def call_tag_parameter_with_default_content(the_tag, attributes, default_content, overriding_content_proc)
      if the_tag.is_a?(String, Symbol) && the_tag.to_s.in?(Hobo.static_tags)
        body = if overriding_content_proc
                 new_context { overriding_content_proc.call(proc { default_content._?.call(nil) }) }
               elsif default_content
                 new_context { default_content.call(nil) }
               else
                 nil
               end
        element(the_tag, attributes, body)
      else
        d = if overriding_content_proc
              proc { |default| overriding_content_proc.call(proc { default_content._?.call(default) }) }
            else
              proc { |default| default_content._?.call(default) }
            end
        send(the_tag, attributes, { :default => d })
      end
    end
    
    
    def call_tag_parameter(the_tag, attributes, parameters, caller_parameters, param_name)
      overriding_proc = caller_parameters[param_name]
      
      if param_name == :default && overriding_proc
        # :default content is handled specially
        
        call_tag_parameter_with_default_content(the_tag, attributes, parameters[:default], overriding_proc)
        
      elsif overriding_proc && overriding_proc.arity == 1
        # The caller is replacing this parameter. Don't call the tag
        # at all, just the overriding proc, but pass the restorable
        # tag as a parameter to the overriding proc
        
        tag_restore = proc do |restore_attrs, restore_params|
          # Call the replaced tag with the attributes and parameters
          # as given in the original tag definition, and with the
          # specialisation given on the 'restore' call
          override_and_call_tag(the_tag, attributes, parameters, restore_attrs, restore_params)
        end
        overriding_proc.call(tag_restore)
        
      else
        overriding_attributes, overriding_parameters = overriding_proc._?.call
        override_and_call_tag(the_tag, attributes, parameters, overriding_attributes, overriding_parameters)
      end     
    end
    
    
    def override_and_call_tag(the_tag, general_attributes, general_parameters, overriding_attributes, overriding_parameters)
      attributes = overriding_attributes ? merge_attrs(general_attributes, overriding_attributes) : general_attributes
      if overriding_parameters
        overriding_default_content = overriding_parameters.delete(:default)
        parameters = general_parameters.merge(overriding_parameters)
      else
        parameters = general_parameters
      end
        
      default_content = parameters[:default]
      
      if the_tag.is_a?(String, Symbol) && the_tag.to_s.in?(Hobo.static_tags)
        body = if overriding_default_content
                 new_context { overriding_default_content.call(proc { default_content._?.call(nil) }) }
               elsif default_content
                 new_context { default_content.call(nil) }
               else
                 nil
               end
        element(the_tag, attributes, body)
      else
        d = if overriding_default_content
              proc { |default| overriding_default_content.call(proc { default_content._?.call(default) }) }
            else
              proc { |default| default_content._?.call(default) }
            end
        parameters = parameters.merge(:default => d)
        
        if the_tag.is_a?(String, Symbol)
          # It's a defined DRYML tag
          send(the_tag, attributes, parameters)
        else
          # It's a proc - restoring a replaced parameter
          the_tag.call(attributes, parameters)
        end
      end
    end


    # This proc is used where 'param' is declared on a tag that is
    # itself a parameter tag.  Takes two procs that each return a pair
    # of hashes (attributes and parameters). Returns a single proc
    # that also returns a pair of hashes - the merged atributes and
    # parameters.
    def merge_tag_parameter(general_proc, overriding_proc)
      if overriding_proc.nil?
        general_proc
      else
        if overriding_proc.arity == 1
          # The override is a replace parameter - just pass it on
          overriding_proc
        else
          proc do 
            overriding_attrs, overriding_parameters = overriding_proc.call
            general_attrs, general_parameters = general_proc.call
            
            attrs  = merge_attrs(general_attrs, overriding_attrs)
            overriding_default = overriding_parameters.delete(:default)
            params = general_parameters.merge(overriding_parameters)
            
            # The overrider should provide its :default as the new
            # 'default_content'
            if overriding_default
              params[:default] = 
                if general_parameters[:default]
                  proc do |default|
                    overriding_default.call(proc { new_context { _output(general_parameters[:default].call(default)) } } )
                  end
                else
                  proc do |default|
                    overriding_default.call(default)
                  end
                end
            end

            [attrs, params]
          end
        end
      end
    end
    

    def part_contexts_storage_tag
      storage = part_contexts_storage
      storage.blank? ? "" : "<script>\n#{storage}</script>\n"
    end
    
    
    def part_contexts_storage
      PartContext.client_side_storage(@_part_contexts, session)
    end
    
    
    def render_tag(tag_name, attributes)
      method_name = tag_name.gsub('-', '_')
      if respond_to?(method_name)
        (send(method_name, attributes) + part_contexts_storage_tag).strip
      else
        false
      end
    end
    
    
    def element(name, attributes, content=nil, escape = true, &block)
      unless attributes.blank?
        attrs = []
        if escape
          attributes.each do |key, value|
            next unless value
            key = key.to_s.gsub("_", "-") 
            
            value = if ActionView::Helpers::TagHelper::BOOLEAN_ATTRIBUTES.include?(key)
                      key
                    else
                      # escape once
                      value.to_s.gsub(/[\"><]|&(?!([a-zA-Z]+|(#\d+));)/) { |special| ERB::Util::HTML_ESCAPE[special] }
                    end
            attrs << %(#{key}="#{value}")
          end
          
        else
          attrs = options.map do |key, value|
            key = key.to_s.gsub("_", "-")
            %(#{key}="#{value}")
          end
        end
        attr_string = " #{attrs.sort * ' '}" unless attrs.empty?
      end
      
      content = new_context(&block) if block_given?
      res = if content
              "<#{name}#{attr_string}>#{content}</#{name}>"
            else
              "<#{name}#{attr_string} />"
            end
      if block && eval("defined? _erbout", block.binding) # in erb context
        _output(res)
      else
        res
      end
    end

  
    def session
      @view ? @view.session : {}
    end
    

    def method_missing(name, *args, &b)
      if @view
        @view.send(name, *args, &b)
      else
        raise NoMethodError, name.to_s
      end
    end
    
  end

end
