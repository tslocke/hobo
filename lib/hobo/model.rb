module Hobo

  module Model

    def self.included(base)
      Hobo.register_model(base)
      base.class_eval do
          # alias_method_chain :find, :block
          # alias_method :rails_original_has_many, :has_many
      end
      base.extend(ClassMethods)
      base.set_field_type({})
    end

    module ClassMethods

      def set_field_type(types)
        @hobo_field_types ||= {}
        @hobo_field_types.update(types)
      end
      
      
      def set_default_order(order)
        @default_order = order
      end
      
      inheriting_attr_accessor :default_order, :id_name_options


      def never_show(*fields)
        @hobo_never_show ||= []
        @hobo_never_show.concat(fields.omap{to_sym})
      end


      def never_show?(field)
        @hobo_never_show and field.to_sym.in?(@hobo_never_show)
      end


      def set_creator_attr(attr)
        class_eval <<-END
          def creator; #{attr}; end
          def creator=(x); self.#{attr} = x; end
        END
      end
          
          
      def set_search_columns(*columns)
        class_eval <<-END
          def self.search_columns
            %w{#{columns.omap{to_s} * ' '}}
          end
        END
      end
        

      def id_name(*args)
        @id_name_options = [] + args
        
        underscore = args.delete(:underscore)
        insenstive = args.delete(:case_insensitive)
        id_name_field = args.first || :name
        @id_name_column = id_name_field.to_s

        if underscore
          class_eval %{
            def id_name(underscore=false)
              underscore ? #{id_name_field}.gsub(' ', '_') : #{id_name_field}
            end
          }
        else
          class_eval %{
            def id_name
              #{id_name_field}
            end
          }
        end

        key = "id_name#{if underscore; ".gsub('_', ' ')"; end}"
        finder = if insenstive
          "find(:first, :conditions => ['lower(name) = ?', #{key}.downcase])"
        else
          "find_by_#{id_name_field}(#{key})"
        end

        class_eval %{
          def self.find_by_id_name(id_name)
            #{finder}
          end
        }

        model = self
        validate do
          erros.add id_name_field, "is taken" if model.find_by_id_name(name)
        end
        validates_format_of id_name_field, :with => /^[^_]+$/, :message => "cannot contain underscores" if
          underscore
      end


      def id_name?
        respond_to?(:find_by_id_name)
      end


      attr_reader :id_name_column


      def field_type(name)
        name = name.to_sym
        @hobo_field_types[name] or
          reflections[name] or
          (col = columns.find {|c| c.name == name.to_s} and col.type)
      end


      def find(*args, &b)
        if args.first.in?([:all, :first])
          if args.last.is_a? Hash
            options = args.last
            args[-1] = options = options.merge(:order => default_order) if options[:order] == :default
          else
            options = {}
          end
          
          if b
            sql = ModelQueries.new(self).instance_eval(&b).to_sql
            super(args.first, options.merge(:conditions => sql))
          else
            super(*args)
          end
        else
          super(*args)
        end
      end


      def subclass_associations(association, *subclass_associations)
        refl = reflections[association]
        for assoc in subclass_associations
          class_name = assoc.to_s.singularize.classify
          has_many(assoc, refl.options.merge(:class_name => class_name,
                                             :source => refl.source_reflection.name,
                                             :conditions => "type = '#{class_name}'"))
        end
      end

      def has_creator?
        instance_methods.include?('creator=') and instance_methods.include?('creator')
      end

      def search_columns
        cols = columns.omap{name}
        %w{name title body content}.select{|c| c.in?(cols) }
      end

    end


    def created_by(user)
      self.creator ||= user if self.class.has_creator? and not user.guest?
    end


    def duplicate
      res = self.class.new
      res.instance_variable_set("@attributes", @attributes.dup)
      res.instance_variable_set("@new_record", nil) unless new_record?
      res
    end


    def same_fields?(other, *fields)
      fields.all?{|f| self.send(f) == other.send(f)}
    end
    
  end
end

