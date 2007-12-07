require 'extensions'

module ::Hobo
  
  class Plugin
    
    class << self
      
      def inherited(base)
        filename = caller[0].match(/^(.*):\d+:/)[1]
        dirname = filename.gsub(/\/init.rb$/, "")
        
        base.meta_eval do 
          attr_accessor :models, :controllers
        end
        
        base.models      = []
        base.controllers = []
        
        eval_ruby_files(base, "#{dirname}/models")
        eval_ruby_files(base, "#{dirname}/controllers") 
      end
      
      
      def plugin_model(name, &block)
        models << [name, block]
      end

      
      def plugin_model_controller(model_name, &block)
        controllers << [model_name, block]
      end
      
      
      private
      
      def eval_ruby_files(base, dir)
        Dir["#{dir}/*.rb"].each do |f|
          base.instance_eval(File.read(f), f, 1)
        end
      end
      
    end
    
    def initialize(options={})
      if options.has_key?(:if)
        if_options = options.delete(:if)
        return unless if_options
        options = options.merge(if_options) if if_options.is_a?(Hash)
      end
      
      @renames, @options = separate_renames(options)

      create_models
      create_controllers
      
      init
    end
    
    attr_accessor :renames, :options
    
    def init
      # optionally overridden by the plugin
    end
    
    private
    
    def create_models
      self.class.models.each do |name, block|
        klass = make_class(new_name_for(name), ActiveRecord::Base)
        klass.class_eval { hobo_model }
        klass.class_eval(&block)
      end
    end
    
    
    def create_controllers
      self.class.controllers.each do |model_name, block|
        klass = make_class("#{new_name_for(model_name).to_s.pluralize}Controller", ApplicationController, &block)
        klass.class_eval { hobo_model_controller }
        klass.class_eval(&block)
      end
    end
    
    
    def make_class(name, base_class)
      klass = Class.new(base_class)
      silence_warnings { Object.const_set(name, klass) }
      me = self
      klass.meta_def :method_missing do |name, *args|
        if name.to_s =~ /^_.*_$/
          me.send(:magic_option, name)
        else
          super
        end
      end
      klass
    end
    
    
    def new_name_for(name)
      name = renames[name] while renames.has_key?(name)
      name
    end
    
    
    def separate_renames(options)
      options.partition_hash { |k, v| k.to_s =~ /[A-Z]/ }
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
      option_name = name.to_s[1..-2].to_sym
      if option_name =~ /^[A-Z]/
        new_name_for(option_name)
      else
        options[option_name] || defaults[option_name]
      end
    end
    
  end
  
end
