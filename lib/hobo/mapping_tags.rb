module Hobo::MappingTags
  
  class InvalidMappingError < RuntimeError; end
  
  class TagOrSelector
    
    def initialize(name, all_mappings)
      @_name = name
      @_dot_names = []
      @_selectors = []
      
      # Keep a reference to the set of mappings for the whole
      # mapping_tags do ... end, so we can remove self if it turns out
      # to be an AttributeValueSelector
      @all_mappings = all_mappings
    end
    
    attr_accessor :_name, :_selectors, :_dot_names

    def method_missing(name)
      raise NoMethodError.new("undefined method: #{name}") if name.to_s =~ /^_|[!?=]$/
      _dot_names << name
      self
    end
    
    
    def [](*selectors)
      raise InvalidMappingError.new unless _selectors.empty?
      
      @_selectors = selectors.omap {_to_selector}
      self
    end
    
    
    def _to_selector
      raise InvalidMappingError.new unless _dot_names.empty? and _selectors.empty?
      AttributeSelector.new(_name)
    end
    
    
    def ==(rhs)
      raise InvalidMappingError.new unless _selectors.empty? and _dot_names.empty?
      AttributeValueSelector.new(_name, rhs)
    end
    
    
    def >>(rhs)
      @all_mappings << Mapping.new(self, rhs)
      nil
    end
    
  end
  
  class AttributeSelector
    
    def initialize(attribute)
      @attribute = attribute
    end
    
    
    def compile
      "options[:#{@attribute}]"
    end
  end
  
  class AttributeValueSelector
    
    def initialize(name, value)
      @name = name
      @value = value
    end
    
    attr_reader :name, :value
    
    def compile
      "(options[:#{@name}] == #{@value.inspect})"
    end
    
    def _to_selector
      self
    end
    
  end
  
  
  class Mapping
    
    def initialize(pattern, result)
      raise InvalidMappingError.new unless result._selectors.empty? and pattern._dot_names.length <= 1
      @pattern = pattern
      @result = result
    end
    
    attr_reader :pattern, :result
    
    
    def pattern_tag_name
      pattern._name
    end
    
    
    def pattern_predicate
      clauses = (pattern._selectors || []).omap{compile}
      type_name = pattern._dot_names.first
      clauses << "(#{type_name.to_s.classify} <= selector_type)" if type_name
      !clauses.empty? && "proc {|options| #{clauses.join(' and ')}}"
    end
    
    
    def result_tag_name
      result._name
    end
    
    
    def result_css_classes
      result._dot_names
    end
    
    
  end
  
  
  class MappingDSL

    def initialize
      @_mappings = []
    end
    
    attr_reader :_mappings
    
    def method_missing(name, &b)
      raise NoMethodError.new("undefined method: #{name}") if name.to_s =~ /^_|[!?=]$/
      TagOrSelector.new(name, @_mappings)
    end
    
  end
  
  (Object.instance_methods +
   Object.private_instance_methods +
   Object.protected_instance_methods).each do |m|
    MappingDSL.send(:undef_method, m) unless
      %w{initialize method_missing send instance_eval}.include?(m) || m.starts_with?('_')
  end
  
  def self.define_mapping_tag(mapping, mod)
    def_name           = mapping.pattern_tag_name
    pred               = mapping.pattern_predicate
    result_tag_name    = mapping.result_tag_name
    result_css_classes = mapping.result_css_classes
    
    static_tag_name = result_tag_name if result_tag_name.to_s.in?(Hobo.static_tags)
      
    if def_name == result_tag_name
      result_tag_name = "#{def_name}_unmapped"
      mod.send(:alias_method, result_tag_name, def_name) if mod.respond_to?(def_name)
    end
    
    mod.define_tag(def_name, [])
    
    # puts "map: #{def_name}[#{pred}] -> #{result_tag_name} (#{result_css_classes * ' '}) #{static_tag_name}"
    
    def_line = if !pred.blank?
                 "defp :#{def_name}, (#{pred}) do |options, block|"
               elsif mod.predicate_method?(def_name)
                 # be sure not to overwrite the predicate dispatch method
                 "defp :#{def_name} do |options, block|"
               else
                 "def #{def_name}(options={}, &block)"
               end
    
    add_classes = result_css_classes.empty? ? "" : "options = add_classes(options, *#{result_css_classes.inspect})"
    
    no_method_fallback = if static_tag_name
                           "content_tag('#{static_tag_name}', tagbody && tagbody.call, options)"
                         else
                           "raise NoMethodError.new('undefined method', '#{result_tag_name}')"
                         end
    
    mod.module_eval(x = <<-END, __FILE__, __LINE__+1)
      #{def_line}
        _tag_context(options, block) do |tagbody|
          #{add_classes}
          if respond_to?('#{result_tag_name}')
            send('#{result_tag_name}', options, &block)
          else
            #{no_method_fallback}
          end
        end
      end
    END
  end
  
  
end
