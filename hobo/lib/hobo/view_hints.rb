module Hobo
  
  class ViewHints
    
    def self.enable
      ActiveSupport::Dependencies.load_paths |= ["#{RAILS_ROOT}/app/viewhints"]
    end
  
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

    setter :field_names, {}
    
    setter :field_help,  {}
    
    setter :children,    [] do |*args|
      # Setting children also gives a default parent using the reverse association
      child_model = model.reflections[args.first].klass
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
      
      def model_name(new_name=nil)
        if new_name.nil?
          @model_name ||= Hobo::Translations.ht("#{_name.tableize}.model_name", :default => _name.titleize)
        else
          @model_name = Hobo::Translations.ht("#{_name.tableize}.model_name", :default => new_name)
        end
      end
                
      def model_name_plural(new_name=nil)
        if new_name.nil?
          @model_name_plural ||= Hobo::Translations.ht("#{_name.tableize}.model_name_plural", :default => model_name.pluralize)
        else
          @model_name_plural = Hobo::Translations.ht("#{_name.tableize}.model_name_plural", :default => new_name)
        end
      end
          
      def model
        @model ||= _name.constantize
      end
        

      def field_name(field)
        Hobo::Translations.ht("#{_name.tableize}.#{field}", :default => field_names.fetch(field.to_sym, field.to_s.titleize))
      end
    
      def primary_children
        children.first
      end
      
      def secondary_children
        children.rest
      end
      
    end
    
  end
  
end    
