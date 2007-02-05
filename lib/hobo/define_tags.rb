module Hobo

  module DefineTags
    
    def self.included(base)
      base.extend(ClassMethods)
      base.extend(PredicateDispatch::ClassMethods)
      base.instance_variable_set("@hobo_tags", HashWithIndifferentAccess.new)
    end

    module ClassMethods
      
      attr_reader :hobo_tags, :hobo_tag_blocks


      def define_tag(name, attrs)
        @hobo_tags[name] = Dryml::TagDef.new(name, attrs)
      end

      
      def def_tag(name, *attrs_and_pred, &tagdef_block)
        pred, attrs = if attrs_and_pred.first.is_a? Proc
                        [attrs_and_pred.first, attrs_and_pred[1..-1]]
                      else
                        [nil, attrs_and_pred]
                      end

        name = name.to_s
        tag = define_tag(name, attrs)
        @hobo_tag_blocks ||= HashWithIndifferentAccess.new
        @hobo_tag_blocks[name] = tagdef_block

        safe_name = Dryml.unreserve(name)
        locals = tag.attrs.map{|a| Hobo::Dryml.unreserve(a)} + ["options"]
        
        def_line = if pred
                     "defp :#{safe_name}, (proc {#{pred}}) do |options, block|"
                   elsif predicate_method?(safe_name)
                     # be sure not to overwrite the predicate dispatch method
                     "defp :#{safe_name} do |options, block|"
                   else
                     "def #{safe_name}(options={}, &block)"
                   end

        src = <<-END
          #{def_line}
            _tag_context(options, block) do |tagbody|
              locals = _tag_locals(options, #{tag.attrs.inspect})
              locals_hash = { :tagbody => tagbody };
              #{locals.inspect}.each_with_index{|a, i| locals_hash[a] = locals[i]}
              Hobo::ProcBinding.new(self, locals_hash).instance_eval(&#{self.name}.hobo_tag_blocks['#{name}'])
            end
          end
        END
        class_eval src, __FILE__, __LINE__
      end
    
      def mapping_tags(&b)
        d = MappingTags::MappingDSL.new
        
        d.instance_eval(&b)
        mappings = d._mappings
        mappings.each {|m| MappingTags.define_mapping_tag(m, self) }
      end
      
    end

  end
  
end
