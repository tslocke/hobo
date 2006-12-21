module Hobo

  module DefineTags

    def self.included(base)
      base.extend(ClassMethods)
      base.instance_variable_set("@hobo_tags", {})
    end

    module ClassMethods

      attr_reader :hobo_tags, :hobo_tag_blocks

      def def_tag(name, *attrs, &tagdef_block)
        raise Exception.new("Error defining tag #{name}: this must be the first tag parameter"
                            ) if attrs.length > 1 and attrs[1..-1].include?(:this)

        name = name.to_s
        @hobo_tags[name] = tag = Dryml::TagDef.new(name, attrs)
        @hobo_tag_blocks ||= {}
        @hobo_tag_blocks[name] = tagdef_block

        safe_name = Dryml.unreserve(name)
        locals = tag.attrs.map{|a| Hobo::Dryml.unreserve(a)} + ["options"]

        src = <<-END
          def #{safe_name}(options={}, &block)
            res = ''
            _tag_context(options, block) do |tagbody|
              locals = _tag_locals(options, #{tag.attrs.inspect})
              locals_hash = { :tagbody => tagbody };
              #{locals.inspect}.each_with_index{|a, i| locals_hash[a] = locals[i]}
              res = Hobo::ProcBinding.new(self, locals_hash).instance_eval(&#{self.name}.hobo_tag_blocks['#{name}'])
            end
            res.to_s
          end
        END
        class_eval src, __FILE__, __LINE__
      end

    end

  end
end
