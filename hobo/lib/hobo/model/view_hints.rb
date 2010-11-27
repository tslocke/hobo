module Hobo
  module Model
    class ViewHints

      def self.setter(name, default=nil, &block)
        ivname = name.to_s.remove(/\?$/)
        metaclass.send :define_method, name do |*args|
          if args.empty?
            val = instance_variable_get("@#{ivname}")
            if val.nil?
              val = default.is_a?(Proc) ? instance_eval(&default) : default
              instance_variable_set("@#{ivname}", val)
            end
            val
          else
            arg = if block
                    instance_exec(*args, &block)
                  else
                    args.first
                  end
            instance_variable_set("@#{ivname}", arg)
          end
        end
      end

      setter :children,    [] do |*args|
        # Setting children also gives a default parent using the reverse association
        child_model = model.reflect_on_association(args.first).klass
        if child_model.view_hints.parent.nil? and !child_model.view_hints.parent_defined
          parent = model.reverse_reflection(args.first)
          child_model.view_hints.parent(parent.name, :undefined => true) if parent
        end
        args
      end

      setter :parent,         nil do |*args|
        options = args.extract_options!
        parent_defined(true) unless options[:undefined]
        args.first
      end

      setter :parent_defined, nil

      setter :paginate?,    proc { !sortable? }

      setter :sortable?,    proc { defined?(ActiveRecord::Acts::List::InstanceMethods) &&
                                   model < ActiveRecord::Acts::List::InstanceMethods &&
                                   model.new.try.scope_condition == "1 = 1" }

      setter :inline_booleans, [] do |*args|
       if args[0] == true
         model.columns.select { |c| c.type == :boolean }.*.name
       else
         args.*.to_s
       end
      end

      # Accessors

      class << self

        def _name
          @_name ||= name.sub(/Hints$/, '')
        end

        def model
          @model ||= _name.constantize
        end

        def primary_children
          children.first
        end

        def secondary_children
          children.rest
        end


  ##### LEGACY METHODS TO REMOVE #####

        def model_name(*)
          raise NotImplementedError, "ViewHints.model_name is no longer supported, please use model.model_name.human and set a the activerecord.models.<model_name> key in a locale file"
        end

        def model_name_plural(*)
          raise NotImplementedError, "ViewHints.model_name_plural is no longer supported, please use model.model_name.human(:count => n) and set a the activerecord.models.<model_name> key in a locale file"
        end

        def field_name(*)
          raise NotImplementedError, "ViewHints.field_name is no longer supported, please use model..human_attribute_name and set a the activerecord.attributes.<model_name>.<field_name> key in a locale file"
        end

        def field_names(*)
          raise NotImplementedError, "ViewHints.field_names is no longer supported, please set the activerecord.attributes.<model_name>.<field_name> keys in a locale file"
        end

      end

    end

  end
end
