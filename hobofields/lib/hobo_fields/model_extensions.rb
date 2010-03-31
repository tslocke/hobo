module HoboFields

  ModelExtensions = classy_module do

    # ignore the model in the migration until somebody sets
    # @include_in_migration via the fields declaration
    inheriting_cattr_reader :include_in_migration => false

    # attr_types holds the type class for any attribute reader (i.e. getter
    # method) that returns rich-types
    inheriting_cattr_reader :attr_types => HashWithIndifferentAccess.new
    inheriting_cattr_reader :attr_order => []

    # field_specs holds FieldSpec objects for every declared
    # field. Note that attribute readers are created (by ActiveRecord)
    # for all fields, so there is also an entry for the field in
    # attr_types. This is redundant but simplifies the implementation
    # and speeds things up a little.
    inheriting_cattr_reader :field_specs => HashWithIndifferentAccess.new

    # index_specs holds IndexSpec objects for all the declared indexes.
    inheriting_cattr_reader :index_specs => []
    inheriting_cattr_reader :ignore_indexes => []

    def self.inherited(klass)
      fields do |f|
        f.field(inheritance_column, :string)
      end
      index(inheritance_column)
      super
    end

    def self.index(fields, options = {})
      # don't double-index fields
      index_specs << HoboFields::IndexSpec.new(self, fields, options) unless index_specs.*.fields.include?(Array.wrap(fields).*.to_s)
    end

    # tell the migration generator to ignore the named index. Useful for existing indexes, or for indexes
    # that can't be automatically generated (for example: an prefix index in MySQL)
    def self.ignore_index(index_name)
      ignore_indexes << index_name.to_s
    end

    private

    # Declares that a virtual field that has a rich type (e.g. created
    # by attr_accessor :foo, :type => :email_address) should be subject
    # to validation (note that the rich types know how to validate themselves)
    def self.validate_virtual_field(*args)
      validates_each(*args) {|record, field, value| msg = value.validate and record.errors.add(field, msg) if value.respond_to?(:validate) }
    end


    # This adds a ":type => t" option to attr_accessor, where t is
    # either a class or a symbolic name of a rich type. If this option
    # is given, the setter will wrap values that are not of the right
    # type.
    def self.attr_accessor_with_rich_types(*attrs)
      options = attrs.extract_options!
      type = options.delete(:type)
      attrs << options unless options.empty?
      public
      attr_accessor_without_rich_types(*attrs)
      private

      if type
        type = HoboFields.to_class(type)
        attrs.each do |attr|
          declare_attr_type attr, type, options
          type_wrapper = attr_type(attr)
          define_method "#{attr}=" do |val|
            if type_wrapper.not_in?(HoboFields::PLAIN_TYPES.values) && !val.is_a?(type) && HoboFields.can_wrap?(type, val)
              val = type.new(val.to_s)
            end
            instance_variable_set("@#{attr}", val)
          end
        end
      end
    end


    # Extend belongs_to so that it creates a FieldSpec for the foreign key
    def self.belongs_to_with_field_declarations(name, options={}, &block)
      column_options = {}
      column_options[:null] = options.delete(:null) if options.has_key?(:null)
      column_options[:comment] = options.delete(:comment) if options.has_key?(:comment)

      index_options = {}
      index_options[:name] = options.delete(:index) if options.has_key?(:index)

      returning belongs_to_without_field_declarations(name, options, &block) do
        refl = reflections[name.to_sym]
        fkey = refl.primary_key_name
        declare_field(fkey.to_sym, :integer, column_options)
        if refl.options[:polymorphic]
          declare_polymorphic_type_field(name, column_options)
          index(["#{name}_type", fkey], index_options) if index_options[:name]!=false
        else
          index(fkey, index_options) if index_options[:name]!=false
        end
      end
    end
    class << self
      alias_method_chain :belongs_to, :field_declarations
    end


    # Declares the "foo_type" field that accompanies the "foo_id"
    # field for a polyorphic belongs_to
    def self.declare_polymorphic_type_field(name, column_options)
      type_col = "#{name}_type"
      declare_field(type_col, :string, column_options)
      # FIXME: Before hobofields was extracted, this used to now do:
      # never_show(type_col)
      # That needs doing somewhere
    end


    # Declare a rich-type for any attribute (i.e. getter method). This
    # does not effect the attribute in any way - it just records the
    # metadata.
    def self.declare_attr_type(name, type, options={})
      klass = HoboFields.to_class(type)
      attr_types[name] = HoboFields.to_class(type)
      klass.try.declared(self, name, options)
    end


    # Declare named field with a type and an arbitrary set of
    # arguments. The arguments are forwarded to the #field_added
    # callback, allowing custom metadata to be added to field
    # declarations.
    def self.declare_field(name, type, *args)
      options = args.extract_options!
      try.field_added(name, type, args, options)
      add_formatting_for_field(name, type, args)
      add_validations_for_field(name, type, args)
      add_index_for_field(name, args, options)
      declare_attr_type(name, type, options) unless HoboFields.plain_type?(type)
      field_specs[name] = HoboFields::FieldSpec.new(self, name, type, options)
      attr_order << name unless name.in?(attr_order)
    end


    # Add field validations according to arguments in the
    # field declaration
    def self.add_validations_for_field(name, type, args)
      validates_presence_of   name if :required.in?(args)
      validates_uniqueness_of name, :allow_nil => !:required.in?(args) if :unique.in?(args)

      type_class = HoboFields.to_class(type)
      if type_class && type_class.public_method_defined?("validate")
        self.validate do |record|
          v = record.send(name)._?.validate
          record.errors.add(name, v) if v.is_a?(String)
        end
      end
    end

    def self.add_formatting_for_field(name, type, args)
      type_class = HoboFields.to_class(type)
      if type_class && "format".in?(type_class.instance_methods)
        self.before_validation do |record|
          record.send("#{name}=", record.send(name)._?.format)
        end
      end
    end

    def self.add_index_for_field(name, args, options)
      to_name = options.delete(:index)
      return unless to_name
      index_opts = {}
      index_opts[:unique] = :unique.in?(args) || options.delete(:unique)
      # support :index => true declaration
      index_opts[:name] = to_name unless to_name == true
      index(name, index_opts)
    end


    # Extended version of the acts_as_list declaration that
    # automatically delcares the 'position' field
    def self.acts_as_list_with_field_declaration(options = {})
      declare_field(options.fetch(:column, "position"), :integer)
      acts_as_list_without_field_declaration(options)
    end


    # Returns the type (a class) for a given field or association. If
    # the association is a collection (has_many or habtm) return the
    # AssociationReflection instead
    def self.attr_type(name)
      if attr_types.nil? && self != self.name.constantize
        raise RuntimeError, "attr_types called on a stale class object (#{self.name}). Avoid storing persistent references to classes"
      end

      attr_types[name] or

        if (refl = reflections[name.to_sym])
          if refl.macro.in?([:has_one, :belongs_to]) && !refl.options[:polymorphic]
            refl.klass
          else
            refl
          end
        end or

        (col = column(name.to_s) and HoboFields::PLAIN_TYPES[col.type] || col.klass)
    end


    # Return the entry from #columns for the named column
    def self.column(name)
      return unless (@table_exists ||= table_exists?)
      name = name.to_s
      columns.find {|c| c.name == name }
    end

    class << self
      alias_method_chain :acts_as_list,  :field_declaration if defined?(ActiveRecord::Acts::List)
      alias_method_chain :attr_accessor, :rich_types
    end

  end

end
