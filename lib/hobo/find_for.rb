module Hobo
  
  # FIXME: should be FindByBelongsTo maybe
  module FindFor
    
    def self.included(base)
      base.alias_method_chain :method_missing, :find_for
    end
    
    def method_missing_with_find_for(name, *args, &block)
      if name.to_s =~ /(.*)_by_(.*)/
        # name matches the general form
        
        collection_name = $1.to_sym
        anchor_association_name = $2.to_sym
        if (refl = self.class.reflections[collection_name]) && refl.macro == :has_many
          # the association name matches (e.g. comment_for_...)
          
          if (anchor_refl = refl.klass.reflections[anchor_association_name]) && anchor_refl.macro == :belongs_to
            # the whole thing matches (e.g. comment_for_user)
            
            
            #self.class.class_eval %{
            #  def #{name}(anchor)
            #    result = if #{collection_name}.loaded?
            #               #{collection_name}.detect { |x| x.#{anchor_association_name}_is?(anchor) }
            #             else
            #               #{collection_name}.#{anchor_association_name}_is(anchor).first
            #             end
            #    result ||= #{collection_name}.new(:#{anchor_association_name} => anchor)
            #    result.origin = self
            #    result.origin_attribute = "#{name}.'#{anchor_id_expr}'"
            #    result
            #  end
            #}
            
            self.class.class_eval %{
              def #{name}
                Hobo::FindFor::Finder.new(self, '#{name}', :#{collection_name}, :#{anchor_association_name})
              end
            }
            
            return send(name, *args)
          end
        end
      end
      
      method_missing_without_find_for(name, *args, &block)
    end
    
    class Finder
      
      def initialize(owner, name, collection, anchor_association)
        @association = owner.send(collection)
        @anchor_reflection = @association.member_class.reflections[anchor_association]
        @name = name
      end
      
      def origin
        @association.proxy_owner
      end
      
      def origin_attribute
        @name
      end
      
      def [](anchor_or_id)
        anchor = if anchor_or_id.is_a?(String)
                   id, klass = anchor_or_id.split(':')
                   (klass.constantize || @anchor_reflection.klass).find(id)
                 else
                   anchor_or_id
                 end
        result = if @association.loaded?
                   @association.detect { |x| x.send("#{@anchor_reflection.name}_is?", anchor) }
                else
                   @association.send("#{@anchor_reflection.name}_is", anchor).first
                end
        result ||= @association.new(@anchor_reflection.name => anchor)


        result.origin = self
        result.origin_attribute = if @anchor_reflection.options[:polymorphic]
                                    "#{anchor.id}:#{anchor.class.name}"
                                  else
                                    "#{anchor.id}"
                                  end
        result
      end

    end

  end

end
