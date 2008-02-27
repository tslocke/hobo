module Hobo

  module Model
    
    class PermissionDeniedError < RuntimeError; end
    
    NAME_FIELD_GUESS      = %w(name title)
    PRIMARY_CONTENT_GUESS = %w(description body content profile)
    SEARCH_COLUMNS_GUESS  = %w(name title body content profile)
    
    
    def self.included(base)
      base.extend(ClassMethods)
      
      included_in_class_callbacks(base)

      Hobo.register_model(base)

      base.class_eval do
        inheriting_cattr_reader :default_order, :id_name_options
        alias_method_chain :attributes=, :hobo_type_conversion
        default_scopes
      end
      
      class << base
        alias_method_chain :has_many,   :defined_scopes
        alias_method_chain :belongs_to, :creator_metadata
        
        alias_method_chain :has_one, :new_method
        
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
      
      
      def field_added(name, type, args, options)
        self.name_attribute            = name.to_sym if options.delete(:name)
        self.primary_content_attribute = name.to_sym if options.delete(:primary_content)
        self.creator_attribute         = name.to_sym if options.delete(:creator)
        validate = options.delete(:validate) {true}
        
        #FIXME - this should be in Hobo::User
        send(:login_attribute=, name.to_sym, validate) if options.delete(:login) && respond_to?(:login_attribute=)
      end
      
      
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
                              cols = columns.*.name
                              NAME_FIELD_GUESS.detect {|f| f.in? columns.*.name }
                            end
      end
      

      def primary_content_attribute
        @primary_content_attribute ||= begin
                                         cols = columns.*.name
                                         PRIMARY_CONTENT_GUESS.detect {|f| f.in? columns.*.name }
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
      
      private
      
            
      def belongs_to_with_creator_metadata(name, options={}, &block)
        self.creator_attribute = name.to_sym if options.delete(:creator)
        belongs_to_without_creator_metadata(name, options, &block)
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

      def never_show?(field)
        (@hobo_never_show && field.to_sym.in?(@hobo_never_show)) || (superclass < Hobo::Model && superclass.never_show?(field))
      end
      public :never_show?

      def set_search_columns(*columns)
        class_eval %{
          def self.search_columns
            %w{#{columns.*.to_s * ' '}}
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

      
      # FIXME: Get rid of this junk :-)
      def conditions(*args, &b)
        if args.empty?
          ModelQueries.new(self).instance_eval(&b)._?.to_sql
        else
          ModelQueries.new(self).instance_exec(*args, &b)._?.to_sql
        end
      end
      
      # FIXME: Get rid of the model-queries stuff from here
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


      def creator_type
        reflections[creator_attribute]._?.klass
      end

      
      def search_columns
        cols = columns.*.name
        SEARCH_COLUMNS_GUESS.select{|c| c.in?(cols) }
      end
      
      
      # FIXME: This should really be a method on AssociationReflection
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
    
    
    def user_destroy(user)
      raise PermissionDeniedError unless Hobo.can_delete?(user, self)
      destroy
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
      
      changed_fields = changed_fields.flatten.*.to_s
      all_cols = self.class.columns.*.name - []
      all_cols.all?{|c| c.in?(changed_fields) || self.send(c) == other.send(c) }
    end
    
    def compose_with(object, use=nil)
      CompositeModel.new_for([self, object])
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
          # TODO: This @foo_1 feature is rarely (never?) used - get rid of it
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
      elsif field_type <= Hobo::Boolean
        (value.is_a?(String) && value.strip.downcase.in?(['0', 'false']) || value.blank?) ? false : true
      else
        # primitive field
        value
      end
    end
        
  end
end


class ActiveRecord::Base
  alias_method :has_hobo_method?, :respond_to_without_attributes?
end
