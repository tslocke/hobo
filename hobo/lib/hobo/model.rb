require 'hobo/lifecycles'

module Hobo

  module Model

    class PermissionDeniedError < RuntimeError; end
    class NoNameError < RuntimeError; end

    NAME_FIELD_GUESS      = %w(name title)
    PRIMARY_CONTENT_GUESS = %w(description body content profile)
    SEARCH_COLUMNS_GUESS  = %w(name title body content profile)


    def self.included(base)
      base.extend(ClassMethods)

      included_in_class_callbacks(base)

      Hobo.register_model(base)

      patch_will_paginate

      base.class_eval do
        inheriting_cattr_reader :default_order
        alias_method_chain :attributes=, :hobo_type_conversion
        attr_accessor :acting_user

        bool_attr_accessor :exempt_from_edit_checks
        
        include Hobo::Lifecycles::ModelExtensions
      end

      class << base
        alias_method_chain :has_many,      :defined_scopes
        alias_method_chain :has_many,      :join_record_management
        alias_method_chain :belongs_to,    :creator_metadata
        alias_method_chain :attr_accessor, :creator_metadata
        
        alias_method_chain :has_one, :new_method

        def inherited(klass)
          super
          fields do
            Hobo.register_model(klass)
            field(klass.inheritance_column, :string)
          end
        end
      end

    end

    def self.patch_will_paginate
      if defined?(WillPaginate) && !WillPaginate::Collection.respond_to?(:member_class)

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
    
    
    def self.enable
      ActiveRecord::Base.class_eval do
        def self.hobo_model
          include Hobo::Model
          fields # force hobofields to load
        end
        
        alias_method :has_hobo_method?, :respond_to_without_attributes?
      end
    end


    module ClassMethods

      # include methods also shared by CompositeModel
      #include ModelSupport::ClassMethods

      attr_accessor :creator_attribute
      attr_writer :name_attribute, :primary_content_attribute

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


      def user_find(user, *args)
        record = find(*args)
        raise PermissionDeniedError unless Hobo.can_view?(user, record)
        record
      end


      def user_new(user, attributes={})
        record = new(attributes)
        record.user_changes(user) and record
      end


      def user_new!(user, attributes={})
        user_new(user, attributes) or raise PermissionDeniedError
      end


      def user_create(user, attributes={})
        record = new(attributes)
        record.user_save_changes(user)
        record
      end


      def user_can_create?(user, attributes={})
        record = new(attributes)
        record.user_changes(user)
      end


      def user_update(user, id, attributes={})
        find(id).user_save_changes(user, attributes)
      end


      def name_attribute
        @name_attribute ||= begin
                              column_names = columns.*.name
                              NAME_FIELD_GUESS.detect {|f| f.in? column_names }
                            end
      end


      def primary_content_attribute
        @primary_content_attribute ||= begin
                                         column_names = columns.*.name
                                         PRIMARY_CONTENT_GUESS.detect {|f| f.in? column_names }
                                       end
      end

      def dependent_collections
        reflections.values.select do |refl|
          refl.macro == :has_many && refl.options[:dependent]
        end.*.name
      end


      def dependent_on
        reflections.values.select do |refl|
          refl.macro == :belongs_to && (rev = reverse_reflection(refl.name) and rev.options[:dependent])
        end.*.name
      end


      def default_dependent_on
        dependent_on.first
      end


      private


      def belongs_to_with_creator_metadata(name, options={}, &block)
        self.creator_attribute = name.to_sym if options.delete(:creator)
        belongs_to_without_creator_metadata(name, options, &block)
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
        has_one_without_new_method(name, options)
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
        if options[:order] == :default
          options = if default_order.blank?
                      options.except :order
                    else
                      options.merge(:order => "#{table_name}.#{default_order}")
                    end
        end
        result = super(*args + [options])
        result.member_class = self if result.is_a?(Array)
        result
      end


      def all(options={})
        find(:all, options.reverse_merge(:order => :default))
      end


      def creator_type
        attr_type(creator_attribute)
      end


      def search_columns
        column_names = columns.*.name
        SEARCH_COLUMNS_GUESS.select{|c| c.in?(column_names) }
      end


      # FIXME: This should really be a method on AssociationReflection
      def reverse_reflection(association_name)
        refl = reflections[association_name]
        return nil if refl.options[:conditions] || refl.options[:polymorphic]

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
          # FIXME: Do we need this now?
          call_method_chain(name, args, &block)
        elsif create_automatic_scope(name)
          send(name, *args, &block)
        else
          super(name.to_sym, *args, &block)
        end
      end


      def call_method_chain(chain, args, &block)
        parts = chain.split(".")
        s = parts[0..-2].inject(self) { |m, scope| m.send(scope) }
        s.send(parts.last, *args)
      end


      def to_url_path
        "#{name.underscore.pluralize}"
      end


      def typed_id
        HoboFields.to_name(self) || name.underscore.gsub("/", "__")
      end


      def manage_join_records(association)

        method = "manage_join_records_for_#{association}"
        after_save method
        class_eval %{
          def #{method}
            assigned = #{association}.dup
            current = #{association}.reload

            through = #{association}.proxy_reflection.through_reflection
            source  = #{association}.proxy_reflection.source_reflection

            to_delete = current - assigned
            to_add    = assigned - current
            through.klass.delete_all(["\#{through.primary_key_name} = ? and \#{source.primary_key_name} in (?)",
                                             self.id, to_delete.*.id]) if to_delete.any?
            to_add.each { |record| #{association} << record }
          end
        }
      end

      def has_many_with_join_record_management(name, options={}, &b)
        manage = options.delete(:managed)
        returning (has_many_without_join_record_management(name, options, &b)) do
          manage_join_records(name) if manage
        end
      end

    end # --- of ClassMethods --- #


    include Scopes

    def to_url_path
      "#{self.class.to_url_path}/#{to_param}" unless new_record?
    end


    def with_acting_user(user)
      old = acting_user
      self.acting_user = user
      result = yield
      self.acting_user = old
      result
    end


    def user_changes(user, changes={})
      with_acting_user user do
        if new_record?
          self.attributes = changes
          set_creator(user)
          Hobo.can_create?(user, self)
        else
          original = duplicate
          # 'duplicate' can cause these to be set, but they can conflict
          # with the changes so we clear them
          clear_aggregation_cache
          clear_association_cache

          self.attributes = changes

          Hobo.can_update?(user, original, self)
        end
      end
    end


    def user_changes!(user, changes={})
      user_changes(user, changes) or raise PermissionDeniedError
    end


    def user_can_create?(user, attributes={})
      raise ArgumentError, "Called #user_can_create? on existing record" unless new_record?
      user_changes(user, attributes)
    end


    def user_save_changes(user, changes={})
      with_acting_user user do
        user_changes!(user, changes)
        save
      end
    end
    
    
    def user_save(user)
      user_save_changes(user)
    end
    
    
    def user_view(user, field=nil)
      raise PermissionDeniedError, self.inspect unless Hobo.can_view?(user, self, field)
    end


    def user_destroy(user)
      with_acting_user user do
        raise PermissionDeniedError unless Hobo.can_delete?(user, self)
        destroy
      end
    end


    def dependent_on
      self.class.dependent_on.map { |assoc| send(assoc) }
    end


    def attributes_with_hobo_type_conversion=(attributes, guard_protected_attributes=true)
      converted = attributes.map_hash { |k, v| convert_type_for_mass_assignment(self.class.attr_type(k), v) }
      send(:attributes_without_hobo_type_conversion=, converted, guard_protected_attributes)
    end


    def set_creator(user)
      set_creator!(user) unless get_creator
    end


    def set_creator!(user)
      attr = self.class.creator_attribute
      return unless attr

      # Is creator a string field or an association?
      if self.class.attr_type(attr)._? <= String
        # Set it to the name of the current user
        self.send("#{attr}=", user.to_s) unless user.guest?
      else  
        # Assume user is a user object, but don't set if we've got a type mismatch
        t = self.class.creator_type
        self.send("#{attr}=", user) if t.nil? || user.is_a?(t)
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

      changed_fields = changed_fields.flatten.*.to_s
      all_cols = self.class.columns.*.name - []
      all_cols.all?{|c| c.in?(changed_fields) || self.send(c) == other.send(c) }
    end


    def compose_with(object, use=nil)
      CompositeModel.new_for([self, object])
    end


    def typed_id
      "#{self.class.name.underscore}_#{self.id}" if id
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
      if field_type.is_a?(Class) && field_type < ActiveRecord::Base
        convert_record_reference_for_mass_assignment(field_type, value)

      elsif field_type.is_a?(ActiveRecord::Reflection::AssociationReflection)
        convert_collection_for_mass_assignment(field_type, value)

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

      elsif field_type <= Hobo::Boolean
        (value.is_a?(String) && value.strip.downcase.in?(['0', 'false']) || value.blank?) ? false : true

      else
        # no conversion
        value
      end
    end


    def convert_record_reference_for_mass_assignment(klass, value)
      if value.is_a?(String)
        if value.starts_with?('@')
          # TODO: This @foo_1 feature is rarely (never?) used - get rid of it
          Hobo.object_from_dom_id(value[1..-1])
        else
          klass.named(value)
        end
      else
        value
      end
    end


    def convert_collection_for_mass_assignment(reflection, value)
      if reflection.klass.try.name_attribute && value.is_a?(Array)
        value.map do |x|
          if x.is_a?(String)
            reflection.klass.named(x) unless x.blank?
          else
            x
          end
        end.compact
      else
        value
      end
    end

  end

end


Hobo::Model.enable if defined? ActiveRecord
