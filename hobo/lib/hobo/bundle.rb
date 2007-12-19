require 'extensions'

module ::Hobo
  
  class Bundle
    
    @bundles = HashWithIndifferentAccess.new
    
    class << self
      
      attr_accessor :bundles, :plugin
      
      def inherited(base)
        filename = caller[0].match(/^(.*):\d+/)[1]
        dirname = filename.match(%r(^.*/plugins/[^/]+))[0]
        base.plugin = File.basename(dirname)
        
        base.meta_eval do 
          attr_accessor :models, :controllers
        end
        
        base.models      = []
        base.controllers = []
        
        eval_ruby_files(base, "#{dirname}/models")
        eval_ruby_files(base, "#{dirname}/controllers") 
      end
      
      
      def bundle_model(name, &block)
        models << [name, block]
      end

      
      def bundle_model_controller(model_name, &block)
        controllers << [model_name, block]
      end
      
      
      private
      
      def eval_ruby_files(base, dir)
        Dir["#{dir}/*.rb"].each do |f|
          base.instance_eval(File.read(f), f, 1)
        end
      end
      
    end
    
    def initialize(*args)
      options = defaults.with_indifferent_access
      options.update(args.extract_options!)
      
      self.name = args.first || self.class.name.match(/[^:]+$/)[0].underscore
      Bundle.bundles[name] = self
      
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
    def defaults; {}; end

    
    def plugin
      self.class.plugin
    end
    
    
    def create_models
      self.class.models.each do |name, block|
        klass = make_class(new_name_for(name), ActiveRecord::Base) do
          hobo_model
        end
        klass.class_eval(&block)
      end
    end
    
    
    def create_controllers
      bundle = self
      self.class.controllers.each do |model_name, block|
        klass = make_class("#{new_name_for(model_name).to_s.pluralize}Controller", ApplicationController) do 
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
      end
      
      klass.meta_def(:bundle) do 
        bundle
      end
      
      klass.meta_def(:_feature) do |feature, block|
        has_feature = bundle.option[feature]
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
      name = renames[name] while renames.has_key?(name)
      name
    end
    
    
    def separate_renames(options)
      simple_options, renames = HashWithIndifferentAccess.new, HashWithIndifferentAccess.new
      options.each do |k, v| 
        if k.to_s =~ /^[A-Z]/
          renames[k] = v.to_s
          renames[k.to_s.underscore] = v.to_s.underscore.to_sym
          renames[k.to_s.underscore.pluralize] = v.to_s.underscore.pluralize.to_sym
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
      elsif options.has_key?(name)
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
      class_name.to_s.constantize.new(name, external_options.merge(local_options))
      self.options["#{option_name}_bundle"] = name
    end

  end
  
end
