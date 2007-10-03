module Hobo

  module Model
    
    PLAIN_TYPES = { :boolean       => TrueClass,
                    :date          => Date,
                    :datetime      => Time,
                    :integer       => Fixnum,
                    :big_integer   => BigDecimal,
                    :float         => Float,
                    :string        => String
                  }
    
    Hobo.field_types.update(PLAIN_TYPES)
    
    def self.included(base)
      Hobo.register_model(base)
      base.extend(ClassMethods)
      base.class_eval do
        @field_specs  = HashWithIndifferentAccess.new
        set_field_type({})
      end
      class << base
        alias_method_chain :has_many, :defined_scopes
        alias_method_chain :belongs_to, :foreign_key_declaration
      end
      # respond_to? is slow on AR objects, use this instead where possible
      base.send(:alias_method, :has_hobo_method?, :respond_to_without_attributes?)
    end

    module ClassMethods
      
      # include methods also shared by CompositeModel
      include ModelSupport::ClassMethods
      
      private
      
      def return_type(type)
        @next_method_type = type
      end
      
      def method_added(name)
        if @next_method_type
          set_field_type(name => @next_method_type)
          @next_method_type = nil
        end
      end
      
      
      def fields(&b)
        dsl = FieldDeclarationsDsl.new(self)
        if b.arity == 1
          yield dsl
        else
          dsl.instance_eval(&b)
        end
      end
      
      
      def belongs_to_with_foreign_key_declaration(name, *args, &block)
        res = belongs_to_without_foreign_key_declaration(name, *args, &block)
        refl = reflections[name]
        fkey = refl.primary_key_name
        field_specs[fkey] ||= FieldSpec.new(self, fkey, :integer)
        if refl.options[:polymorphic]
          type_col = "#{name}_type"
          field_specs[type_col] ||= FieldSpec.new(self, type_col, :string)
        end
        res
      end
      
      
      attr_reader :field_specs
      public :field_specs
      
      def set_field_type(types)
        types.each_pair do |field, type|
          type_class = Hobo.field_types[type] || type
          field_types[field] = type_class
          
          if "validate".in?(type_class.instance_methods)
            self.validate do |record|
              v = record.send(field)._?.validate
              record.errors.add(field, v) if v.is_a?(String)
            end
          end
        end
      end
      
      
      def field_types
        @hobo_field_types ||= superclass.respond_to?(:field_types) ? superclass.field_types : {}
      end
      
      
      def set_default_order(order)
        @default_order = order
      end
      
      inheriting_attr_accessor :default_order, :id_name_options


      def never_show(*fields)
        @hobo_never_show ||= []
        @hobo_never_show.concat(fields.every(:to_sym))
      end

      def never_show?(field)
        @hobo_never_show and field.to_sym.in?(@hobo_never_show)
      end
      public :never_show?

      def set_creator_attr(attr)
        @creator_attr = attr.to_sym
      end 
      attr_reader :creator_attr
      public :creator_attr

      def set_search_columns(*columns)
        class_eval %{
          def self.search_columns
            %w{#{columns.every(:to_s) * ' '}}
          end
        }
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
            def id_name(underscore=false)
              #{id_name_field}
            end
          }
        end

        key = "id_name#{if underscore; ".gsub('_', ' ')"; end}"
        finder = if insenstive
          "find(:first, :conditions => ['lower(#{id_name_field}) = ?', #{key}.downcase])"
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

      public
      
      def id_name?
        respond_to?(:find_by_id_name)
      end

      attr_reader :id_name_column

      
      def field_type(name)
        name = name.to_sym
        field_types[name] or
          reflections[name] or begin
                                 col = columns.find {|c| c.name == name.to_s} rescue nil
                                 return nil if col.nil?
                                 case col.type
                                 when :boolean
                                   TrueClass
                                 when :text
                                   Hobo::Text
                                 else
                                   col.klass
                                 end
                               end
      end
      
      
      def column(name)
        columns.find {|c| c.name == name.to_s} rescue nil
      end
      
      
      def conditions(*args, &b)
        if args.empty?
          ModelQueries.new(self).instance_eval(&b).to_sql
        else
          ModelQueries.new(self).instance_exec(*args, &b).to_sql
        end
      end
      

      def find(*args, &b)
        options = args.extract_options!
        if args.first.in?([:all, :first]) && options[:order] == :default
          options = if default_order.blank?
                      options - [:order]
                    else
                      options.merge(:order => "#{table_name}.#{default_order}")
                    end
        end
          
        res = if b && !(block_conditions = conditions(&b)).blank?
                c = if !options[:conditions].blank?
                      "(#{options[:conditons]}) and (#{block_conditions})"
                    else
                      block_conditions
                    end
                super(args.first, options.merge(:conditions => c))
              else
                super(*args + [options])
              end
        if args.first == :all
          def res.member_class
            @member_class
          end
          res.instance_variable_set("@member_class", self)
        end
        res
      end
      
      
      def count(*args, &b)
        if b
          sql = ModelQueries.new(self).instance_eval(&b).to_sql
          options = extract_options_from_args!(args)
          super(*args + [options.merge(:conditions => sql)])
        else
          super(*args)
        end
      end


      def subclass_associations(association, *subclass_associations)
        refl = reflections[association]
        for assoc in subclass_associations
          class_name = assoc.to_s.classify
          options = { :class_name => class_name, :conditions => "type = '#{class_name}'" }
          options[:source] = refl.source_reflection.name if refl.source_reflection
          has_many(assoc, refl.options.merge(options))
        end
      end

      def creator_type
        reflections[@creator_attr]._?.klass
      end

      def search_columns
        cols = columns.every(:name)
        %w{name title body content}.select{|c| c.in?(cols) }
      end
      
      # This should really be a method on AssociationReflection
      def reverse_reflection(association_name)
        refl = reflections[association_name]
        return nil if refl.options[:conditions]
        
        reverse_macro = if refl.macro == :has_many
                          :belongs_to
                        elsif refl.macro == :belongs_to
                          :has_many
                        end
        refl.klass.reflections.values.find do |r|
          r.macro == reverse_macro and
            r.klass == self and 
            !r.options[:conditions] and
            r.primary_key_name == refl.primary_key_name
        end
      end
      
      
      class ScopedProxy
        def initialize(klass, scope={})
          @klass = klass
          
          # If there's no :find, or :create specified, assume it's a find scope
          @scope = if scope.has_key?(:find) || scope.has_key?(:create)
                     scope
                   else
                     { :find => scope }
                   end
        end
        
        def method_missing(name, *args, &block)
          @klass.send(:with_scope, @scope) do
            @klass.send(name, *args, &block)
          end
        end
        
        def all
          self.find(:all)
        end
        
        def first
          self.find(:first)
        end
      end
      (Object.instance_methods + 
       Object.private_instance_methods +
       Object.protected_instance_methods).each do |m|
        ScopedProxy.send(:undef_method, m) unless
          m.in?(%w{initialize method_missing send}) || m.starts_with?('_')
      end
      
      attr_accessor :defined_scopes

      
      def def_scope(name, scope=nil, &block)
        @defined_scopes ||= {}
        @defined_scopes[name.to_sym] = block || scope
        
        meta_def(name) do |*args|
          ScopedProxy.new(self, block ? block.call(*args) : scope)
        end
      end
      
      
      module DefinedScopeProxyExtender
        
        attr_accessor :reflections
        
        def method_missing(name, *args, &block)
          scope = (proxy_reflection.klass.respond_to?(:defined_scopes) and
                   scopes = proxy_reflection.klass.defined_scopes and 
                   scopes[name.to_sym])
          
          scope = scope.call(*args) if scope.is_a?(Proc)
          
          # If there's no :find, or :create specified, assume it's a find scope
          find_scope = if scope && (scope.has_key?(:find) || scope.has_key?(:create))
                         scope[:find]
                       else
                         scope
                       end
          
          if find_scope
            # Calling instance_variable_get directly causes self to
            # get loaded, hence this trick
            assoc = Kernel.instance_method(:instance_variable_get).bind(self).call("@#{name}_scope")
            
            unless assoc
              options = proxy_reflection.options
              has_many_conditions = options[:conditions]
              source = proxy_reflection.source_reflection
              scope_conditions = find_scope[:conditions]
              conditions = if has_many_conditions && scope_conditions
                             "(#{scope_conditions}) AND (#{has_many_conditions})"
                           else
                             scope_conditions || has_many_conditions
                           end
              
              options = options.merge(find_scope).update(:conditions => conditions,
                                                         :class_name => proxy_reflection.klass.name,
                                                         :foreign_key => proxy_reflection.primary_key_name)
              options[:source] = source.name if source

              r = ActiveRecord::Reflection::AssociationReflection.new(:has_many,
                                                                      name,
                                                                      options,
                                                                      proxy_owner.class)
              
              @reflections ||= {}
              @reflections[name] = r
              
              assoc = if source
                        ActiveRecord::Associations::HasManyThroughAssociation
                      else
                        ActiveRecord::Associations::HasManyAssociation
                      end.new(self.proxy_owner, r)

              # Calling directly causes self to get loaded
              Kernel.instance_method(:instance_variable_set).bind(self).call("@#{name}_scope", assoc)
            end
            assoc
          else
            super
          end
        end
        
      end
      
      
      def has_many_with_defined_scopes(name, *args, &block)
        options = args.extract_options!
        if options.has_key?(:extend) || block
          # Normal has_many
          has_many_without_defined_scopes(name, *args + [options], &block)
        else
          options[:extend] = DefinedScopeProxyExtender
          has_many_without_defined_scopes(name, *args + [options], &block)
        end
      end
    end
    
    
    def set_creator(user)
      self.send("#{self.class.creator_attr}=", user) if (t = self.class.creator_type) && user.is_a?(t)
    end


    def duplicate
      res = self.class.new
      res.instance_variable_set("@attributes", @attributes.dup)
      res.instance_variable_set("@new_record", nil) unless new_record?
      
      # Shallow copy of belongs_to associations
      for refl in self.class.reflections.values
        if refl.macro == :belongs_to and (target = self.send(refl.name))
          bta = ActiveRecord::Associations::BelongsToAssociation.new(res, refl)
          bta.replace(target)
          res.instance_variable_set("@#{refl.name}", bta)
        end
      end
      res
    end


    def same_fields?(other, *fields)
      fields.all?{|f| self.send(f) == other.send(f)}
    end
    
    def only_changed_fields?(other, *changed_fields)
      changed_fields = changed_fields.every(:to_s)
      all_cols = self.class.columns.every(:name)
      all_cols.all?{|c| c.in?(changed_fields) || self.send(c) == other.send(c) }
    end
    
    def compose_with(object, use=nil)
      CompositeModel.new_for([self, object])
    end
    
    def created_date
      created_at.to_date
    end
    
    def modified_date
      modified_at.to_date
    end

    def typed_id
      id ? "#{self.class.name.underscore}_#{self.id}" : nil
    end
    
    def to_s
      if respond_to? :title
        title
      elsif respond_to? :name
        name
      else
        "#{self.class.name.humanize} #{id}"
      end
    end
    
  end
end


# Hack AR to get Hobo type wrappers in

module ActiveRecord::AttributeMethods::ClassMethods

  # Define an attribute reader method.  Cope with nil column.
  def define_read_method(symbol, attr_name, column)
    cast_code = column.type_cast_code('v') if column
    access_code = cast_code ? "(v=@attributes['#{attr_name}']) && #{cast_code}" : "@attributes['#{attr_name}']"

    unless attr_name.to_s == self.primary_key.to_s
      access_code = access_code.insert(0, "missing_attribute('#{attr_name}', caller) " +
                                       "unless @attributes.has_key?('#{attr_name}'); ")
    end

    # This is the Hobo hook - add a type wrapper around the field
    # value if we have a special type defined
    src = if connected? && respond_to?(:field_type) && (type_wrapper = field_type(symbol)) &&
              type_wrapper.is_a?(Class) && type_wrapper.not_in?(Hobo::Model::PLAIN_TYPES.values)
            "val = begin; #{access_code}; end; " +
              "if val.nil? || (val.respond_to?(:hobo_undefined?) && val.hobo_undefined?); val; " + 
              "else; puts(self.class.field_type(:#{attr_name})); self.class.field_type(:#{attr_name}).new(val); end"
          else
            access_code
          end
    
    evaluate_attribute_method(attr_name, 
                              "def #{symbol}; @attributes_cache['#{attr_name}'] ||= begin; #{src}; end; end")
  end
  
  def define_write_method(attr_name)
    src = if connected? && respond_to?(:field_type) && (type_wrapper = field_type(attr_name)) &&
              type_wrapper.is_a?(Class) && type_wrapper.not_in?(Hobo::Model::PLAIN_TYPES.values)
            "if val.nil? || (val.respond_to?(:hobo_undefined?) && val.hobo_undefined?); val; " + 
              "else; self.class.field_type(:#{attr_name}).new(val); end"
          else
            "val"
          end
    evaluate_attribute_method(attr_name, "def #{attr_name}=(val); " + 
                              "write_attribute('#{attr_name}', #{src});end", "#{attr_name}=")
    
  end

end
