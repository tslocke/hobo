module Hobo
  module Model
    require 'will_paginate/active_record'
    require 'will_paginate/array'

    class NoNameError < RuntimeError; end

    NAME_FIELD_GUESS      = %w(name title)
    PRIMARY_CONTENT_GUESS = %w(description body content profile)
    SEARCH_COLUMNS_GUESS  = %w(name title body description content profile)


    def self.included(base)
      base.extend(ClassMethods)

      register_model(base)

      base.class_eval do
        inheriting_cattr_reader :default_order

        cattr_accessor :hobo_controller
        self.hobo_controller = {}

        include Permissions
        include Lifecycles::ModelExtensions
        include FindFor
        include AccessibleAssociations
        include IncludeInSave
      end

      class << base
        alias_method_chain :belongs_to,    :creator_metadata
        alias_method_chain :belongs_to,    :test_methods
        alias_method_chain :attr_accessor, :creator_metadata

        alias_method_chain :has_one, :new_method
      end

      base.fields(false) # force hobo_fields to load

      included_in_class_callbacks(base)
    end

    def self.register_model(model)
      @model_names ||= Set.new
      @model_names << model.name
    end


    def self.all_models
      # Load every model in app/models...
      unless @models_loaded
        Dir.entries("#{Rails.root}/app/models/").each do |f|
          f =~ /^[a-zA-Z_][a-zA-Z0-9_]*\.rb$/ and f.sub(/.rb$/, '').camelize.constantize
        end
        @models_loaded = true
      end

      @model_names ||= Set.new
      # ...but only return the ones that registered themselves
      @model_names.map do |name|
        name.safe_constantize || (@model_names.delete name; nil)
      end.compact
    end


    def self.find_by_typed_id(typed_id)
      return nil if typed_id == 'nil'

      _, name, id, attr = *typed_id.match(/^([^:]+)(?::([^:]+)(?::([^:]+))?)?$/)
      raise ArgumentError.new("invalid typed-id: #{typed_id}") unless name

      model_class = name.camelize.safe_constantize or raise ArgumentError.new("no such class in typed-id: #{typed_id}")
      return nil unless model_class

      if id
        obj = model_class.find(id)
          # Optimise: can we use eager loading in the situation where the attr is a belongs_to?
          # We used to, but hit a bug in AR
        attr ? obj.send(attr) : obj
      else
        model_class
      end
    end

    module ClassMethods

      # TODO: should this be an inheriting_cattr_accessor as well? Probably.
      attr_accessor :creator_attribute
      inheriting_cattr_accessor :name_attribute => Proc.new { |c|
        NAME_FIELD_GUESS.detect {|f| f.in? c.send(:attrib_names) }
      }

      inheriting_cattr_accessor :primary_content_attribute => Proc.new { |c|
        PRIMARY_CONTENT_GUESS.detect {|f| f.in? c.send(:attrib_names) }
      }


      def named(*args)
        raise NoNameError, "Model #{name} has no name attribute" unless name_attribute
        send("find_by_#{name_attribute}", *args)
      end


      def field_added(name, type, args, options)
        self.name_attribute            = name.to_sym if options.delete(:name)
        self.primary_content_attribute = name.to_sym if options.delete(:primary_content)
        self.creator_attribute         = name.to_sym if options.delete(:creator)
        validate = options.delete(:validate) {true}

        #FIXME - this should be in Hobo::Model::UserBase
        send(:login_attribute=, name.to_sym, validate) if options.delete(:login) && respond_to?(:login_attribute=)
      end

      # eval avoids the ruby 1.9.2 "super from singleton method ..." error
      eval %(
        def inherited(klass)
          super
          Hobo::Model.register_model(klass)
          # TODO: figure out when this is needed, as Hobofields already does this
          fields(false) do
            field(klass.inheritance_column, :string)
          end
        end
      )

      private

      def attrib_names
        names = []
        names += table_exists? ? content_columns.*.name : field_specs.keys
        names += public_instance_methods.*.to_s
      end

      def belongs_to_with_creator_metadata(name, options={}, &block)
        self.creator_attribute = name.to_sym if options.delete(:creator)
        belongs_to_without_creator_metadata(name, options, &block)
      end

      def belongs_to_with_test_methods(name, options={}, &block)
        belongs_to_without_test_methods(name, options, &block)
        refl = reflections[name]
        id_method = refl.options[:primary_key] || refl.klass.primary_key
        if options[:polymorphic]
          # TODO: the class lookup in _is? below is incomplete; a polymorphic association to an STI base class
          #       will fail to match an object of a derived type
          #       (ie X belongs_to Y (polymorphic), Z is a subclass of Y; @x.y_is?(some_z) will never pass)
          class_eval %{
            def #{name}_is?(target)
              target.class.name == self.#{refl.foreign_type} && target.#{id_method} == self.#{refl.foreign_key}
            end
            def #{name}_changed?
              #{refl.foreign_key}_changed? || #{refl.foreign_type}_changed?
            end
          }
        else
          id_method = refl.options[:primary_key] || refl.klass.primary_key
          class_eval %{
            def #{name}_is?(target)
              our_id = self.#{refl.foreign_key}
              # if our_id is nil, only return true if target is nil
              return target.nil? unless our_id
              target.class <= ::#{refl.klass.name} && target.#{id_method} == our_id
            end
            def #{name}_changed?
              #{refl.foreign_key}_changed?
            end
          }
        end
      end


      def attr_accessor_with_creator_metadata(*args)
        options = args.extract_options!
        if options.delete(:creator)
          if args.length == 1
            self.creator_attribute = args.first.to_sym
          else
            raise ArgumentError, "trying to set :creator => true on multiple attributes"
          end
        end
        args << options unless options.empty?
        attr_accessor_without_creator_metadata(*args)
      end


      def has_one_with_new_method(name, options={}, &block)
        has_one_without_new_method(name, options, &block)
        class_eval "def new_#{name}(attributes={}); build_#{name}(attributes, false); end"
      end


      def set_default_order(order)
        @default_order = order
      end


      def never_show(*fields)
        @hobo_never_show ||= []
        @hobo_never_show.concat(fields.*.to_sym)
      end


      def set_search_columns(*columns)
        class_eval %{
          def self.search_columns
            %w{#{columns.*.to_s * ' '}}
          end
        }
      end


      public


      def never_show?(field)
        (@hobo_never_show && field.to_sym.in?(@hobo_never_show)) || (superclass < Hobo::Model && superclass.never_show?(field))
      end


      def find(*args)
        result = super
        result.member_class = self if result.is_a?(Array)
        result
      end


      def find_by_sql(*args)
        result = super
        result.member_class = self # find_by_sql always returns array
        result
      end


      def creator_type
        attr_type(creator_attribute)
      end


      def search_columns
        column_names = columns.*.name
        SEARCH_COLUMNS_GUESS.select{|c| c.in?(column_names) }
      end


      def reverse_reflection(association_name)
        refl = reflections[association_name.to_sym] or raise "No reverse reflection for #{name}.#{association_name}"
        return nil if refl.options[:conditions] || refl.options[:polymorphic]

        if refl.macro == :has_many && (self_to_join = refl.through_reflection)
          # Find the reverse of a has_many :through (another has_many :through)

          join_to_self  = reverse_reflection(self_to_join.name)
          join_to_other = refl.source_reflection
          other_to_join = self_to_join.klass.reverse_reflection(join_to_other.name)

          return nil if self_to_join.options[:conditions] || join_to_other.options[:conditions]

          refl.klass.reflections.values.find do |r|
            r.macro == :has_many &&
              !r.options[:conditions] &&
              !r.options[:scope] &&
              r.through_reflection == other_to_join &&
              r.source_reflection  == join_to_self
          end
        else
          # Find the :belongs_to that corresponds to a :has_one / :has_many or vice versa

          reverse_macros = case refl.macro
                           when :has_many, :has_one
                             [:belongs_to]
                           when :belongs_to
                             [:has_many, :has_one]
                           end

          refl.klass.reflections.values.find do |r|
            r.macro.in?(reverse_macros) &&
              r.klass >= self &&
              !r.options[:conditions] &&
              !r.options[:scope] &&
              r.foreign_key.to_s == refl.foreign_key.to_s
          end
        end
      end


      def has_inheritance_column?
        columns_hash.include?(inheritance_column)
      end


      def method_missing(name, *args, &block)
        name = name.to_s
        if create_automatic_scope(name)
          send(name.to_sym, *args, &block)
        else
          super(name.to_sym, *args, &block)
        end
      end


      def respond_to?(method, include_private=false)
        super || create_automatic_scope(method, true)
      end


      def to_url_path
        "#{name.underscore.pluralize}"
      end


      def typed_id
        HoboFields.to_name(self) || name.underscore.gsub("/", "__")
      end


      def view_hints
        class_name = "#{name}Hints"
        class_name.safe_constantize or Object.class_eval("class #{class_name} < Hobo::Model::ViewHints; end; #{class_name}")
      end

      def children(*args)
        view_hints.children *args
      end

      def inline_booleans(*args)
        view_hints.inline_booleans *args
      end

      def table_exists?
        @table_exists_cache = super if @table_exists_cache.nil?
        @table_exists_cache
      end


    end # --- of ClassMethods --- #


    include Scopes


    def to_url_path
      "#{self.class.to_url_path}/#{to_param}"
    end


    def to_param
      name_attr = self.class.name_attribute and name = send(name_attr)
      if name_attr && !name.blank? && id.is_a?(Fixnum)
        readable = name.to_s.downcase.gsub(/[^a-z0-9]+/, '-').remove(/-+$/).remove(/^-+/).split('-')[0..5].join('-')
        @to_param ||= "#{id}-#{readable}"
      else
        id.to_s
      end
    end


    # We deliberately give these three methods unconventional (java-esque) names to avoid
    # polluting the application namespace

    def set_creator(user)
      set_creator!(user) unless get_creator
    end


    def set_creator!(user)
      attr = self.class.creator_attribute
      return unless attr

      attr_type = self.class.creator_type

      # Is creator an instance, a string field or an association?
      if !attr_type.is_a?(Class)
        # attr_type is an instance - typically AssociationReflection for a polymorphic association
        self.send("#{attr}=", user)
      elsif self.class.attr_type(attr)._? <= String
        # Set it to the name of the current user
        self.send("#{attr}=", user.to_s) unless user.guest?
      else
        # Assume user is a user object, but don't set if we've got a type mismatch
        self.send("#{attr}=", user) if attr_type.nil? || user.is_a?(attr_type)
      end
    end


    def get_creator
      self.class.creator_attribute && send(self.class.creator_attribute)
    end


    def typed_id
      "#{self.class.name.underscore}:#{self.id}" if id
    end


    def to_s
      if self.class.name_attribute
        send self.class.name_attribute
      else
        "#{self.class.model_name.human} #{id}"
      end
    end
  end

end
