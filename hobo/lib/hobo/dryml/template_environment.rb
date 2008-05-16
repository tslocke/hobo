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


    for attr in [:erb_binding, :part_contexts, :view_name,
                 :this, :this_parent, :this_field, :this_key,
                 :form_field_path, :form_this, :form_field_names]
      class_eval "def #{attr}; @_#{attr}; end"
    end
    
    def this_key=(key)
      @_this_key = key
    end
    
    
    # The type of this, or when this is nil, the type that would be expected in the current field
    def this_type
      @_this_type ||= if this == false || this == true
                        Hobo::Boolean
                      elsif this
                        this.class
                      elsif this_parent && this_field && (parent_class = this_parent.class).respond_to?(:attr_type)
                        type = parent_class.attr_type(this_field)
                        if type.is_a?(ActiveRecord::Reflection::AssociationReflection)
                          reflection = type
                          if reflection.macro == :has_many
                            Array
                          elsif reflection.options[:polymorphic]
                            # All we know is that it will be some active-record type
                            ActiveRecord::Base
                          else
                            reflection.klass
                          end
                        else
                          type
                        end
                      else
                        # Nothing to go on at all 
                        Object
                      end
    end
    
    
    def this_field_reflection
      this.try.proxy_reflection ||
        (this_parent && this_field && this_parent.class.respond_to?(:reflections) && this_parent.class.reflections[this_field.to_sym])
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

    
    def dom_id(object=nil, attribute=nil)      
      if object.nil?
        # nothing passed -- use context
        if this_parent && this_field
          object, attribute = this_parent, this_field
        else
          object = this
        end
      end
      
      id = object.try.typed_id
      if id
        attribute ? "#{id}_#{attribute}" : id
      else
        "nil"
      end
    end
    
    
    def call_part(part_node_id, part_name, part_this=nil, *locals)
      res = ''
      if part_this
        new_object_context(part_this) do
          @_part_contexts[part_node_id] = PartContext.new(part_name, dom_id, locals)
          res = send("#{part_name}_part", *locals)
        end
      else
        new_context do
          @_part_contexts[part_node_id] = PartContext.new(part_name, dom_id, locals)
          res = send("#{part_name}_part", *locals)
        end
      end
      res
    end

    
    def call_polymorphic_tag(name, *args)
      name = name.to_s.gsub('-', '_')
      type = args.first.is_a?(Class) ? args.shift : nil
      attributes, parameters = args
      
      tag = find_polymorphic_tag(name, type)
      if tag != name
        send(tag, attributes || {}, parameters || {})
      else
        nil
      end
    end

    
    def find_polymorphic_tag(name, call_type=nil)
      call_type ||= (this.is_a?(Array) && this.respond_to?(:member_class) && this.member_class) || this_type

      while true
        if respond_to?(poly_name = "#{name}__for_#{call_type.name.to_s.underscore.gsub('/', '__')}")
          return poly_name
        else
          if call_type == ActiveRecord::Base || call_type == Object
            return name
          else
            call_type = call_type.superclass
          end
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
              @_form_field_path ]
      @_erb_output = ""
      @_this_type = nil
      res = yield
      @_erb_output, @_this, @_this_parent, @_this_field, @_this_type, @_form_field_path = ctx
      res.to_s
    end


    def new_object_context(new_this)
      new_context do
        @_this_parent, @_this_field = [new_this.origin, new_this.origin_attribute] if new_this.respond_to?(:origin) 
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
        @_this, @_this_parent, @_this_field = obj, parent, field
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
      replacing_proc  = caller_parameters[:"#{param_name}_replacement"]
      
      if param_name == :default && overriding_proc
        # :default content is handled specially
        
        call_tag_parameter_with_default_content(the_tag, attributes, parameters[:default], overriding_proc)

      elsif replacing_proc
        # The caller is replacing this parameter. Don't call the tag
        # at all, just the overriding proc, but pass the restorable
        # tag as a parameter to the overriding proc
        
        tag_restore = proc do |restore_attrs, restore_params|
          # Call the replaced tag with the attributes and parameters
          # as given in the original tag definition, and with the
          # specialisation given on the 'restore' call
          
          if overriding_proc
            overriding_attributes, overriding_parameters = overriding_proc.call
            restore_attrs  = overriding_attributes.merge(restore_attrs)
            restore_params = overriding_parameters.merge(restore_params)
          end
          
          override_and_call_tag(the_tag, attributes, parameters, restore_attrs, restore_params)
        end
        replacing_proc.call(tag_restore)
        
        
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
    

    def part_contexts_javascripts
      storage = part_contexts_storage
      storage.blank? ? "" : "<script>\n#{storage}</script>\n"
    end
    
    
    def part_contexts_storage
      PartContext.client_side_storage(@_part_contexts, session)
    end
    
    
    def render_tag(tag_name, attributes)
      method_name = tag_name.to_s.gsub('-', '_')
      if respond_to?(method_name)
        res = (send(method_name, attributes) + part_contexts_javascripts).strip

        # TODO: Temporary hack to get the dryml metadata comments in the right place
        if false && RAILS_ENV == "development"
          res.gsub(/^(.*?)(<!DOCTYPE.*?>).*?(<html.*?>)/m, "\\2\\3\\1") 
        else
          res
        end
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
