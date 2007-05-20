module Hobo

  module DefineTags
    
    def self.included(base)
      base.extend(ClassMethods)
      base.extend(PredicateDispatch::ClassMethods)
    end

    module ClassMethods
      
      attr_reader :hobo_tag_blocks

      
      def def_tag(name, *attrs_and_pred, &tagdef_block)
        pred, attrs = if attrs_and_pred.first.is_a? Proc
                        [attrs_and_pred.first, attrs_and_pred[1..-1]]
                      else
                        [nil, attrs_and_pred]
                      end

        name = name.to_s
        @hobo_tag_blocks ||= HashWithIndifferentAccess.new
        @hobo_tag_blocks[name] = tagdef_block
        @hobo_tag_blocks["#{name}_predicate"] = pred if pred

        safe_name = Dryml.unreserve(name)
        locals = attrs.map{|a| Hobo::Dryml.unreserve(a)} + %w{options inner_tag_options}
        
        def_line = if pred
                     "defp :#{safe_name}, @hobo_tag_blocks['#{name}_predicate'] do |options, block|"
                   elsif predicate_method?(safe_name)
                     # be sure not to overwrite the predicate dispatch method
                     "defp :#{safe_name} do |options, block|"
                   else
                     "def #{safe_name}(options={}, &block)"
                   end

        class_eval(<<-END, __FILE__, __LINE__+1)
          #{def_line}
            _tag_context(options, block) do |tagbody|
              locals = _tag_locals(options, #{attrs.inspect}, [])
              locals_hash = { :tagbody => tagbody };
              #{locals.inspect}.each_with_index{|a, i| locals_hash[a] = locals[i]}
              Hobo::ProcBinding.new(self, locals_hash).instance_eval(&#{self.name}.hobo_tag_blocks['#{name}'])
            end
          end
        END
        
      end
    
    end

  end
  
end
