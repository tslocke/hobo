module Hobo::MappingTags
  
  class Pattern
    
    def initialize(name, ancestor_constraints, type_constraint, block)
      @_name = name
      @_ancestor_constraints = ancestor_constraints
      @_type_constraint = type_constraint
      @_block = block
    end
    
    attr_reader :_name, :_ancestor_constraints, :_type_constraint, :_block
    
    def >(other)
      raise ArgumentError.new("invalid > constraint for mapping: #{name}") if block
      new_contraints = _ancestor_constraints +
        [_name, _type_constraint] +
        other._ancestor_constraints
      Pattern.new(other.name, new_contraints, other._type_constraint, other._block)
    end
    
    def method_missing(name)
      raise NoMethodError.new("undefined method", name) if name.to_s.starts_with?('_')
      @_type_constraint = name.classify.constantize
      self
    end
    
    
    def _predicate
      if _type_constraint
        "selector_type == #{_type_constraint.name}"
      end
    end
    
  end
  
  class PatternBinding

    attr_reader :defined_tags
    
    def initialize
      @result_binding = ResultBinding.new
      @_mappings = []
    end
    
    attr_reader :_mappings
    
    def method_missing(name, &b)
      raise NoMethodError.new("undefined method", name) if name.to_s.starts_with?('_')
      Pattern.new(name, [], nil, b)
    end
    
    def map(pattern)
      result = @result_binding.instance_eval(&pattern._block)
      @_mappings << [pattern, result]
    end
    
  end
  
  Result = Struct.new :tag, :css_classes
  class Result
    
    def method_missing(name)
      css_classes << name
      self
    end
    
  end
  
  class ResultBinding
    
    def method_missing(name)
      Result.new(name, [])
    end
    
  end
  
  
  def self.define_mapping_tag(mapping, mod)
    pattern, result = mapping
    pred = pattern._predicate
    mod.define_tag(pattern._name, [])
    
    puts "map: #{pattern._name} -> #{result.tag} (#{result.css_classes * ' '})"
    
    def_line = if pred
                 "defp :#{pattern._name}, (proc {#{pred}}) do |options, block|"
               elsif mod.predicate_method?(pattern._name)
                 # be sure not to overwrite the predicate dispatch method
                 "defp :#{pattern._name} do |options, block|"
               else
                 "def #{pattern._name}(options={}, &block)"
               end
    mod.module_eval "
      #{def_line}
        res = ''
        _tag_context(options, block) do |tagbody|
          if respond_to?('#{result.tag}')
            opts = add_classes(options, *#{result.css_classes.inspect})
            send('#{result.tag}', opts, &block)
          elsif '#{result.tag}'.in? Hobo.static_tags
            if tagbody
              content_tag('#{result.tag}', tagbody.call, options)
            else
              tag('#{result.tag}', options)
            end
          else
            raise NoMethodError.new('undefined method', '#{result.tag}')
          end
        end
      end
    "
  end
  
end
