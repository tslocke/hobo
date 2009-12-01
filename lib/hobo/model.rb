module Hobo

  module Model

    class NoNameError < RuntimeError; end

    NAME_FIELD_GUESS      = %w(name title)
    PRIMARY_CONTENT_GUESS = %w(description body content profile)
    SEARCH_COLUMNS_GUESS  = %w(name title body description content profile)


    def self.included(base)
      base.extend(ClassMethods)

      register_model(base)

      patch_will_paginate

      base.class_eval do
        inheriting_cattr_reader :default_order
        alias_method_chain :attributes=, :hobo_type_conversion

        include Hobo::Permissions
        include Hobo::Lifecycles::ModelExtensions
        include Hobo::FindFor
        include Hobo::AccessibleAssociations
        include Hobo::Translations
      end

      class << base
        alias_method_chain :belongs_to,    :creator_metadata
        alias_method_chain :belongs_to,    :test_methods
        alias_method_chain :attr_accessor, :creator_metadata

        alias_method_chain :has_one, :new_method

        def inherited(klass)
          super
          fields(false) do
            Hobo.register_model(klass)
            field(klass.inheritance_column, :string)
          end
        end
      end
      
      base.fields(false) # force hobofields to load

      included_in_class_callbacks(base)
    end

    def self.patch_will_paginate
      if defined?(WillPaginate::Collection) && !WillPaginate::Collection.respond_to?(:member_class)

        WillPaginate::Collection.class_eval do
          attr_accessor :member_class, :origin, :origin_attribute
        end

        WillPaginate::Finder::ClassMethods.class_eval do
          def paginate_with_hobo_metadata(*args, &block)
            returning paginate_without_hobo_metadata(*args, &block) do |collection|
              collection.member_class     = self
              collection.origin           = try.proxy_owner
              collection.origin_attribute = try.proxy_reflection._?.name
            end
          end
          alias_method_chain :paginate, :hobo_metadata

        end

      end
    end
    
    
    def self.register_model(model)
      @model_names ||= Set.new
      @model_names << model.name
    end


    def self.all_models
      # Load every controller in app/controllers...
      unless @models_loaded
        Dir.entries("#{RAILS_ROOT}/app/models/").each do |f|
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


    def self.enable
      require 'active_record/association_collection'
      require 'active_record/association_proxy'
      require 'active_record/association_reflection'

      ActiveRecord::Base.class_eval do
        def self.hobo_model
          include Hobo::Model
          fields(false) # force hobofields to load
        end
        def self.hobo_user_model
          include Hobo::Model
          include Hobo::User
        end
        alias_method :has_hobo_method?, :respond_to_without_attributes?
        
        Hobo::Permissions.enable
      end
    end


    module ClassMethods
      require 'active_record/viewhints_validations_interceptor'
      include Hobo::ViewHintsValidationsInterceptor

      # TODO: should this be an inheriting_cattr_accessor as well? Probably.
      attr_accessor :creator_attribute
      inheriting_cattr_accessor :name_attribute => Proc.new { |c|
        names = c.columns.*.name + c.public_instance_methods.*.to_s
        NAME_FIELD_GUESS.detect {|f| f.in? names }
      }

      inheriting_cattr_accessor :primary_content_attribute => Proc.new { |c|
        names = c.columns.*.name + c.public_instance_methods.*.to_s
        PRIMARY_CONTENT_GUESS.detect {|f| f.in? names }
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

        #FIXME - this should be in Hobo::User
        send(:login_attribute=, name.to_sym, validate) if options.delete(:login) && respond_to?(:login_attribute=)
      end


      private


      def belongs_to_with_creator_metadata(name, options={}, &block)
        self.creator_attribute = name.to_sym if options.delete(:creator)
        belongs_to_without_creator_metadata(name, options, &block)
      end

      def belongs_to_with_test_methods(name, options={}, &block)
        belongs_to_without_test_methods(name, options, &block)
        refl = reflections[name]
        if options[:polymorphic]
          # TODO: the class lookup in _is? below is incomplete; a polymorphic association to an STI base class
          #       will fail to match an object of a derived type
          #       (ie X belongs_to Y (polymorphic), Z is a subclass of Y; @x.y_is?(some_z) will never pass)
          class_eval %{
            def #{name}_is?(target)
              target.class.name == self.#{refl.options[:foreign_type]} && target.id == self.#{refl.primary_key_name}
            end
            def #{name}_changed?
              #{refl.primary_key_name}_changed? || #{refl.options[:foreign_type]}_changed?
            end
          }
        else
          class_eval %{
            def #{name}_is?(target)
              target.class <= ::#{refl.klass.name} && target.id == self.#{refl.primary_key_name}
            end
            def #{name}_changed?
              #{refl.primary_key_name}_changed?
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


      def find(*args, &b)
        options = args.extract_options!
        if options[:order] == :default || (options[:order].blank? && !scoped?(:find, :order))
          # TODO: decide if this is correct. AR is no help, as passing :order to a scoped proxy
          #       MERGES the order, but nesting two scopes with :order completely ignores the 
          #       first scope's order.
          #       Are we more like default_scope, or more like passing :order => model.default_order?
          options = if default_order.blank?
                      options.except :order
                    else
                      options.merge(:order => if default_order[/(\.|\(|,| )/]
                                                default_order
                                              else
                                                "#{quoted_table_name}.#{default_order}"
                                              end)
                    end
        end
        result = super(*args + [options])
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
              r.primary_key_name == refl.primary_key_name
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
        super || create_automatic_scope(method)
      end


      def to_url_path
        "#{name.underscore.pluralize}"
      end


      def typed_id
        HoboFields.to_name(self) || name.underscore.gsub("/", "__")
      end
      
      
      def view_hints
        class_name = "#{name}Hints"
        class_name.safe_constantize or Object.class_eval("class #{class_name} < Hobo::ViewHints; end; #{class_name}")
      end


    end # --- of ClassMethods --- #


    include Scopes


    def to_url_path
      "#{self.class.to_url_path}/#{to_param}" unless new_record?
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


    def attributes_with_hobo_type_conversion=(attributes, guard_protected_attributes=true)
      converted = attributes.map_hash { |k, v| convert_type_for_mass_assignment(self.class.attr_type(k), v) }
      send(:attributes_without_hobo_type_conversion=, converted, guard_protected_attributes)
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
        "#{self.class.name.titleize} #{id}"
      end
    end


    private


    def convert_type_for_mass_assignment(field_type, value)
      if !field_type.is_a?(Class)
        value

      elsif field_type <= Date
        if value.is_a? Hash
          parts = %w{year month day}.map{|s| value[s].to_i}
          if parts.include?(0)
            nil
          else
            Date.new(*parts)
          end
        else
          value
        end

      elsif field_type <= Time || field_type <= ActiveSupport::TimeWithZone
        if value.is_a? Hash
          parts = %w{year month day hour minute second}.map{|s| value[s].to_i}
          if parts[0..2].include?(0)
            nil
          else
            Time.zone ? Time.zone.local(*parts) : Time.local(*parts)
          end
        else
          value
        end

      elsif field_type <= Hobo::Boolean
        (value.is_a?(String) && value.strip.downcase.in?(['0', 'false']) || value.blank?) ? false : true

      else
        # no conversion
        value
      end
    end


  end

end


Hobo::Model.enable if defined? ActiveRecord
