module Hobo

  module Model
    
    class PermissionDeniedError < RuntimeError; end
    
    NAME_FIELD_GUESS      = %w(name title)
    PRIMARY_CONTENT_GUESS = %w(description body content profile)
    SEARCH_COLUMNS_GUESS  = %w(name title body content profile)
    
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
      base.extend(ClassMethods)
      
      included_in_class_callbacks(base)

      Hobo.register_model(base)

      base.class_eval do
        alias_method_chain :attributes=, :hobo_type_conversion
        default_scopes
      end
      
      class << base
        alias_method_chain :has_many, :defined_scopes
        alias_method_chain :belongs_to, :foreign_key_declaration
        alias_method_chain :belongs_to, :hobo_metadata
        alias_method_chain :belongs_to, :scopes
        
        alias_method_chain :has_one, :new_method
        
        alias_method_chain :acts_as_list, :fields if defined?(ActiveRecord::Acts::List)
        
        alias_method_chain :attr_accessor, :rich_types
        
        def inherited(klass)
          fields do
            Hobo.register_model(klass)
            field(klass.inheritance_column, :string)
          end
        end
      end
      
    end
    
    module ClassMethods
      
      # include methods also shared by CompositeModel
      #include ModelSupport::ClassMethods
      
      attr_accessor :creator_attribute
      attr_writer :name_attribute, :primary_content_attribute
      
      def user_new(user, attributes={})
        record = new(attributes)
        record.user_changes(user)
        record
      end
      
      
      def user_create(user, attributes={})
        record = new(attributes)
        record.user_save_changes(user)
        record
      end
      
      
      def default_scopes
        def_scope :recent do |*args|
          count = args.first || 3
          { :limit => count, :order => "#{table_name}.created_at DESC" }
        end
        def_scope :limit do |count|
          { :limit => count }
        end
      end
      
      def name_attribute
        @name_attribute ||= begin
                              cols = columns.every :name
                              NAME_FIELD_GUESS.detect {|f| f.in? columns.every(:name) }
                            end
      end
      

      def primary_content_attribute
        @primary_content_attribute ||= begin
                                         cols = columns.every :name
                                         PRIMARY_CONTENT_GUESS.detect {|f| f.in? columns.every(:name) }
                                       end
      end
      
      def dependent_collections
        reflections.values.select do |refl| 
          refl.macro == :has_many && refl.options[:dependent]
        end.every(:name)
      end
      
      
      def dependent_on
        reflections.values.select do |refl| 
          refl.macro == :belongs_to && (rev = reverse_reflection(refl.name) and rev.options[:dependent])
        end.every(:name)
      end
      
      private
      
      
      def validate_virtual_field(*args)
        validates_each(*args) {|record, field, value| msg = value.validate and errors.add(field, msg) if value.respond_to?(:validate) }
      end
      
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
      
      
      # This adds a :type => ??? option to attr_accessor. If this
      # option is given, the setter will wrap values that are not of
      # the right type.
      def attr_accessor_with_rich_types(*attrs)
        options = attrs.extract_options!
        type = options[:type]
        if type
          type = Hobo.field_types[type] if type.is_a?(Symbol)
          attrs.each do |attr|
            set_field_type attr => type
            define_method "#{attr}=" do |val|
              unless val.nil? || val.is_a?(type) || (val.respond_to?(:hobo_undefined?) && val.hobo_undefined?)
                val = type.new(val)
              end
              instance_variable_set("@#{attr}", val)
            end
          end
          
          attr_reader *attrs
        else
          attr_accessor_without_rich_types(*attrs)
        end
      end
      
      
      def belongs_to_with_foreign_key_declaration(name, options={}, &block)
        res = belongs_to_without_foreign_key_declaration(name, options, &block)
        refl = reflections[name]
        fkey = refl.primary_key_name
        column_options = {}
        column_options[:null] = options[:null] if options.has_key?(:null)
        field_specs[fkey] ||= FieldSpec.new(self, fkey, :integer, column_options)
        if refl.options[:polymorphic]
          type_col = "#{name}_type"
          field_specs[type_col] ||= FieldSpec.new(self, type_col, :string, column_options)
          never_show(type_col)
        end
        res
      end
      
      
      def belongs_to_with_hobo_metadata(name, options={}, &block)
        self.creator_attribute = name.to_sym if options.delete(:creator)
        belongs_to_without_hobo_metadata(name, options, &block)
      end
      
      
      def belongs_to_with_scopes(name, options={}, &block)
        belongs_to_without_scopes(name, options, &block)
        key = reflections[name].primary_key_name
        if options[:polymorphic]
          def_scope "#{name}_is" do |record|
            { :conditions => ["#{table_name}.#{key} = ? AND #{name}_type = ?", record.id, record.class.name] }
          end
          def_scope "#{name}_is_not" do |record|
            { :conditions => ["#{table_name}.#{key} <> ? OR #{name}_type <> ?", record.id, record.class.name] }
          end
        else
          def_scope "#{name}_is" do |record|
            { :conditions => ["#{table_name}.#{key} = ?", record.id] }
          end
          def_scope "#{name}_is_not" do |record|
            { :conditions => ["#{table_name}.#{key} <> ?", record.id] }
          end
        end
      end
      
      
      def has_one_with_new_method(name, options={}, &block)
        has_one_without_new_method(name, options)
        class_eval "def new_#{name}(attributes={}); build_#{name}(attributes, false); end"
      end


      def acts_as_list_with_fields(options = {})
        fields { |f| f.send(options._?[:column] || "position", :integer) }
        acts_as_list_without_fields(options)
      end


      def field_specs
        @field_specs ||= HashWithIndifferentAccess.new
      end
      public :field_specs
      
      def set_field_type(types)
        types.each_pair do |field, type|
          type_class = Hobo.field_types[type] || type
          field_types[field] = type_class
          
          if type_class && "validate".in?(type_class.instance_methods)
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
        (@hobo_never_show && field.to_sym.in?(@hobo_never_show)) || (superclass < Hobo::Model && superclass.never_show?(field))
      end
      public :never_show?

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
          "find(:first, options.merge(:conditions => ['lower(#{id_name_field}) = ?', #{key}.downcase]))"
        else
          "find_by_#{id_name_field}(#{key}, options)"
        end

        class_eval %{
          def self.find_by_id_name(id_name, options={})
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
          if (refl = reflections[name])
            if refl.macro.in?(:has_one, :belongs_to)
              refl.klass
            else
              refl
            end
          end or begin
            col = column(name)
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
          ModelQueries.new(self).instance_eval(&b)._?.to_sql
        else
          ModelQueries.new(self).instance_exec(*args, &b)._?.to_sql
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
                      "(#{sanitize_sql options[:conditions]}) AND (#{sanitize_sql block_conditions})"
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
      
      
      def all(options={})
        find(:all, options.reverse_merge(:order => :default))
      end
      
      
      def count(*args, &b)
        if b
          sql = ModelQueries.new(self).instance_eval(&b).to_sql
          options = args.extract_options!
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
        reflections[creator_attribute]._?.klass
      end

      def search_columns
        cols = columns.every(:name)
        SEARCH_COLUMNS_GUESS.select{|c| c.in?(cols) }
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
          r.macro == reverse_macro &&
            r.klass == self &&
            !r.options[:conditions] &&
            r.primary_key_name == refl.primary_key_name
        end
      end
      
      
      def has_inheritance_column?
        columns_hash.include?(inheritance_column)
      end
      

      def method_missing(name, *args, &block)
        name = name.to_s
        if name =~ /\./
          parts = name.split(".")
          s = parts[0..-2].inject(self) { |m, scope| m.send(scope) }
          s.send(parts.last, *args)
        else
          super(name.to_sym, *args, &block)
        end
      end

    end # --- of ClassMethods --- #
    
    
    include Scopes
    
    
    def user_changes(user, changes={})
      if new_record?
        self.attributes = changes
        set_creator(user) 
        raise PermissionDeniedError unless Hobo.can_create?(user, self)
      else
        original = duplicate
        # 'duplicate' can cause these to be set, but they can conflict
        # with the changes so we clear them
        clear_aggregation_cache
        clear_association_cache
        
        self.attributes = changes
        
        raise PermissionDeniedError unless Hobo.can_update?(user, original, self)
      end        
    end
    
    
    def user_save_changes(user, changes={})
      user_changes(user, changes)
      save
    end
    
    
    def user_view(user)
      raise PermissionDeniedError unless Hobo.can_view?(user, self)
    end
    
    
    def user_destory(user)
      raise PermissionDeniedError unless Hobo.can_delete?(user, self)
      destroy
    end
    
    
    def dependent_on
      self.class.dependent_on.map { |assoc| send(assoc) }
    end
    
    
    def attributes_with_hobo_type_conversion=(attributes, guard_protected_attributes=true)
      converted = attributes.map_hash { |k, v| convert_type_for_mass_assignment(self.class.field_type(k), v) }
      send(:attributes_without_hobo_type_conversion=, converted, guard_protected_attributes)
    end
      

    
    def set_creator(user)
      set_creator!(user) unless get_creator
    end
    
    
    def set_creator!(user)
      attr = self.class.creator_attribute
      return unless attr
      
      # Is creator a string field or an association?
      if self.class.reflections[attr]
        # It's an association
        self.send("#{attr}=", user) if (t = self.class.creator_type) && user.is_a?(t)
      else
        # Assume it's a string field -- set it to the name of the current user
        self.send("#{attr}=", user.to_s) unless user.guest?
      end
    end
    
    
    # We deliberately give this method an unconventional name to avoid
    # polluting the application namespace too badly
    def get_creator
      self.class.creator_attribute && send(self.class.creator_attribute)
    end


    def duplicate
      copy = self.class.new
      copy.copy_instance_variables_from(self, ["@attributes_cache"])
      copy.instance_variable_set("@attributes", @attributes.dup)
      copy.instance_variable_set("@new_record", nil) unless new_record?
      
      # Shallow copy of belongs_to associations
      for refl in self.class.reflections.values
        if refl.macro == :belongs_to and (target = self.send(refl.name))
          bta = ActiveRecord::Associations::BelongsToAssociation.new(copy, refl)
          bta.replace(target)
          copy.instance_variable_set("@#{refl.name}", bta)
        end
      end
      copy
    end


    def same_fields?(other, *fields)
      return true if other.nil?
      
      fields = fields.flatten
      fields.all?{|f| self.send(f) == other.send(f)}
    end
    
    def only_changed_fields?(other, *changed_fields)
      return true if other.nil?
      
      changed_fields = changed_fields.flatten.every(:to_s)
      all_cols = self.class.columns.every(:name) - []
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
      if self.class.name_attribute
        send self.class.name_attribute
      else
        "#{self.class.name.titleize} #{id}"
      end
    end
    
    private
    
    def parse_datetime(s)
      defined?(Chronic) ? Chronic.parse(s) : Time.parse(s)
    end

    def convert_type_for_mass_assignment(field_type, value)
      if field_type.is_a?(ActiveRecord::Reflection::AssociationReflection) &&
          field_type.macro.in?([:belongs_to, :has_one])
        if value.is_a?(String) && value.starts_with?('@')
          Hobo.object_from_dom_id(value[1..-1])
        else
          value
        end
      elsif !field_type.is_a?(Class)
        value
      elsif field_type <= Date
        if value.is_a? Hash
          Date.new(*(%w{year month day}.map{|s| value[s].to_i}))
        elsif value.is_a? String
          dt = parse_datetime(value)
          dt && dt.to_date
        else
          value
        end
      elsif field_type <= Time
        if value.is_a? Hash
          Time.local(*(%w{year month day hour minute}.map{|s| value[s].to_i}))
        elsif value.is_a? String
          parse_datetime(value)
        else
          value
        end
      elsif field_type <= TrueClass
        (value.is_a?(String) && value.strip.downcase.in?(['0', 'false']) || value.blank?) ? false : true
      else
        # primitive field
        value
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
              "else; self.class.field_type(:#{attr_name}).new(val); end"
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

class ActiveRecord::Base
  alias_method :has_hobo_method?, :respond_to_without_attributes?
end
