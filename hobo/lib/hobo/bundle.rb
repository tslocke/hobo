module ::Hobo

  class Bundle

    @bundles = HashWithIndifferentAccess.new

    class << self

      # Hobo::Bundle.bundles is a hash of all instantiated bundles by name
      attr_accessor :bundles

      # Used by subclasses, e.g MyBundle.plugin is the name of the
      # plugin the bundle came from
      attr_reader :plugin

      attr_reader :model_declarations, :controller_declarations

      attr_accessor :dirname

      def inherited(base)
        filename = caller[0].match(/^(.*):\d+/)[1]
        base.dirname = filename.match(%r(^.*/plugins/[^/]+))[0]
      end


      def load_models_and_controllers
        return if models_and_controllers_loaded?

        @plugin = File.basename(dirname)

        @model_declarations      = []
        @controller_declarations = []

        class_eval do
          eval_ruby_files("#{dirname}/models", @models)
          eval_ruby_files("#{dirname}/controllers", @controllers)
        end
      end

      def [](bundle_name)
        bundles[bundle_name]
      end


      private

      def bundle_model(name, &block)
        @model_declarations << [name, block]
      end


      def bundle_model_controller(model_name, &block)
        @controller_declarations << [model_name, block]
      end


      def models_and_controllers_loaded?
        @model_declarations
      end



      def eval_ruby_files(dir, filenames)
        files = if filenames == [:none]
                  []
                elsif filenames.blank? || filenames == [:all]
                  Dir["#{dir}/*.rb"]
                else
                  filenames.map { |f| "#{dir}/#{f}.rb" }
                end

        files.each { |f| instance_eval(File.read(f), f, 1) }
      end


      # Declarations

      def models(*models)
        @models = models
      end

      def controllers(*controllers)
        @controllers = controllers.map {|c| case c.to_s
                                              when /controller$/, "all", "none" then c
                                              else "#{c.to_s.pluralize}_controller"
                                            end }
      end

    end

    def initialize(*args)
      caller_options = args.extract_options!

      self.class.load_models_and_controllers
      self.name = args.first || self.class.name.match(/[^:]+$/)[0].underscore
      Bundle.bundles[name] = self

      options = defaults(caller_options).with_indifferent_access
      options.recursive_update(caller_options)

      @renames, @options = separate_renames(options)

      includes

      create_models
      create_controllers

      init
    end

    attr_accessor :renames, :options, :name

    # optionally overridden by the bundle subclass
    def includes; end
    def init;     end
    def defaults(options); {}; end


    def plugin
      self.class.plugin
    end


    def create_models
      self.class.model_declarations.each do |name, block|
        klass = make_class(new_name_for(name), ActiveRecord::Base)

        klass.meta_def :belongs_to_with_optional_polymorphism do |*args|
          opts = args.extract_options!

          if opts[:polymorphic] == :optional
            if bundle.options["polymorphic_#{name}"]
              opts[:polymorphic] = true
              opts.delete(:class_name)
            else
              opts.delete(:polymorphic)
            end
          end
          belongs_to_without_optional_polymorphism(name, opts)
        end
        klass.meta_eval { alias_method_chain :belongs_to, :optional_polymorphism }

        klass.class_eval { hobo_model }

        # FIXME this extension breaks passing a block to belongs_to
        klass.meta_def :belongs_to_with_alias do |*args|
          opts = args.extract_options!
          name = args.first.to_sym

          alias_name = opts.delete(:alias)

          belongs_to_without_alias(name, opts)

          if alias_name && name != alias_name
            klass.send(:alias_method, alias_name, name)
            # make the aliased name available in the classes metadata
            klass.reflections[alias_name] = klass.reflections[name]
          end

        end
        klass.meta_eval { alias_method_chain :belongs_to, :alias }

        klass.class_eval(&block)
      end
    end


    def create_controllers
      bundle = self
      self.class.controller_declarations.each do |model_name, block|
        klass = make_class("#{new_name_for(model_name).to_s.pluralize}Controller", ::ApplicationController) do
          hobo_model_controller
        end
        klass.class_eval(&block)
      end
    end


    def make_class(name, base_class, &b)
      bundle = self
      klass = Class.new(base_class) do
        # Nasty hack because blocks can't take blocks
        # Roll on Ruby 1.9
        def self.feature(name, &block)
          _feature(name, block)
        end

        def method_missing(name, *args)
          if name.to_s =~ /^_.*_$/
            self.class.bundle.magic_option(name)
          else
            super
          end
        end
      end

      klass.meta_def(:bundle) do
        bundle
      end

      klass.meta_def(:_feature) do |feature, block|
        has_feature = bundle.options[feature]
        if has_feature
          define_method("features_#{feature}?") { true }
          meta_def("features_#{feature}?") { true }
          block.call if block
        else
          define_method("features_#{feature}?") { false }
          meta_def("features_#{feature}?") { false }
        end
      end
      silence_warnings { Object.const_set(name, klass) }

      klass.meta_def :method_missing do |name, *args|
        if name.to_s =~ /^_.*_$/
          bundle.magic_option(name)
        else
          super
        end
      end

      klass.class_eval(&b) if b

      klass
    end


    def new_name_for(name)
      name = name.to_s
      underscore = name =~ /^[a-z]/
      name = name.camelize if underscore

      plural = !renames.has_key?(name) && (sing = name.singularize) && renames.has_key?(sing)
      name = sing if plural

      # Keep a track of names we've seen to avoid cycles
      seen = [ name ]

      name = name.gsub(/_.*?_/) { |s| new_name_for(s[1..-2]) }
      while (newname = renames[name])
        name = newname
        name = name.gsub(/_.*?_/) { |s| new_name_for(s[1..-2]) }

        break if name.in?(seen)
        seen << name
      end

      name = name.underscore if underscore
      name = name.pluralize  if plural
      name = name.to_sym if underscore || plural
      name
    end


    def separate_renames(options)
      simple_options, renames = HashWithIndifferentAccess.new, HashWithIndifferentAccess.new
      options.each do |k, v|
        if k.to_s =~ /^[A-Z]/
          renames[k] = v.to_s
        else
          simple_options[k] = v
        end
      end
      [renames, simple_options]
    end


    def customize(name, &block)
      new_name_for(name).to_s.constantize.class_eval(&block)
    end


    def method_missing(name, *args)
      if name.to_s =~ /^_.*_$/
        magic_option(name)
      else
        super
      end
    end


    # Returns the option value or renamed class name from a 'magic'
    # name like _foo_ or _MyFoo_
    def magic_option(name)
      option_name = name.to_s[1..-2]
      if option_name == "bundle"
        self.name
      elsif options.has_key?(option_name)
        options[option_name]
      else
        new_name_for(option_name)
      end
    end


    def optional_bundle(*args)
      local_options = args.extract_options!
      class_name, option_name = args
      option_name ||= class_name.to_s.underscore
      _include_bundle(class_name, option_name, local_options) if self.options[option_name]
    end


    def include_bundle(*args)
      local_options = args.extract_options!
      class_name, option_name = args
      option_name ||= class_name.to_s.underscore
      _include_bundle(class_name, option_name, local_options)
    end


    def _include_bundle(class_name, option_name, local_options)
      external_options = self.options[option_name]
      external_options = {} if external_options.nil? || external_options == true
      name = "#{self.name}_#{option_name}"

      sub_bundle_options = external_options.merge(local_options).merge(renames)
      sub_bundle = class_name.to_s.constantize.new(name, sub_bundle_options)

      conflicting_renames = (renames.keys & sub_bundle.renames.keys).select { |k| renames[k] != sub_bundle.renames[k] }
      unless conflicting_renames.empty?
        raise ArgumentError, "Conflicting renames in included bundle '#{name}' of '#{self.name}': #{conflicting_renames * ', '}"
      end
      renames.update(sub_bundle.renames)
      self.options["#{option_name}_bundle"] = name
    end

  end

end
