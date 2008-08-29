require 'set'
require 'fileutils'

module Hobo
  
  module Dryml
    
    class DrymlGenerator
      
      TEMPLATES = "#{HOBO_ROOT}/dryml_generators"
      OUTPUT    = "#{RAILS_ROOT}/app/views/taglibs/auto"
      
      HEADER = "<!-- AUTOMATICALLY GENERATED FILE - DO NOT EDIT -->\n\n"
      
      def self.run
        @generator ||= DrymlGenerator.new
        @generator.run
      end
      
      
      def initialize
        @templates = {}
        @digests   = {}
        load_templates
      end
      
      attr_accessor :subsite
      
      
      def load_templates
        Dir["#{TEMPLATES}/**/*.erb.dryml"].each do |f|
          name = f[TEMPLATES.length + 1..-11]
          erb = File.read(f)
          @templates[name] = ERB.new(erb, nil, '-').src
          
          # Create output directories and parents as required
          [nil, *Hobo.subsites].each do |s| 
            FileUtils.mkdir_p(File.dirname("#{output_dir s}/#{name}"))
          end
        end
      end
      
      
      def run
        [nil, *Hobo.subsites].each { |s| run_for_subsite(s) }
      end
      
      
      def run_for_subsite(subsite)
        self.subsite = subsite
        @templates.each_pair do |name, src|
          run_one(name, src)
        end        
      end
      
      
      def output_dir(s=subsite)
        s ? "#{OUTPUT}/#{s}" : OUTPUT
      end
      
      
      def run_one(name, src)
        dryml = instance_eval(src, name)
        if dryml_changed?(name, dryml)
          out = HEADER + dryml
          File.open("#{output_dir}/#{name}.dryml", 'w') { |f| f.write(out) }
        end
      end
      
      
      def dryml_changed?(name, dryml)
        key = "#{subsite}/#{name}"
        d = digest dryml
        if d != @digests[key]
          @digests[key] = d
          true
        else
          false
        end
      end
      
      
      def digest(s)
        OpenSSL::Digest::Digest.digest('sha1', s)
      end
      
      
      # --- Helper methods for the templates --- #
      
      attr_reader :controller
      
      
      def controllers
        Hobo::ModelController.all_controllers(subsite)
      end
      
      
      def models 
        Hobo::Model.all_models
      end
      
      def each_controller
        controllers.each do |controller|
          @controller = controller
          yield
        end
        @controller = nil
      end
      
      
      def each_model
        models.each do |model|
          @model = model
          yield
        end
        @model = nil
      end
      
      
      def model
        @model || @controller.model
      end
      
      
      def model_name(*options)
        name = model.name
        name = name.pluralize                                 if :plural.in?(options)
        name = name.titleize                                  if :title.in?(options)
        name = name.titleize.downcase                         if :lowercase.in?(options)
        name = name.underscore.gsub('_', '-').gsub('/', '--') if :dashed.in?(options)
        name
      end
      
      
      def model_class
        model_name(:dashed)
      end

      
      def primary_collection_name(klass=model)
        dependent_collection_names = klass.reflections.values.select do |refl|
          refl.macro == :has_many && refl.options[:dependent]
        end.*.name

        (dependent_collection_names - through_collection_names(klass)).first
      end


      def through_collection_names(klass=model)
        klass.reflections.values.select do |refl|
          refl.macro == :has_many && refl.options[:through]
        end.map {|x| x.options[:through]}
      end


      def linkable?(*args)
        options = args.extract_options!
        options[:subsite] = subsite
        klass, action = if args.length == 1
                          [model, args.first]
                        else
                          args
                        end
        Hobo::ModelRouter.linkable?(klass, action, options)
      end  


      def should_be_sortable?
        raise "just pasting this junk in here for now"
        first = this.first and
          first.respond_to?(:position_column) and
          reorder_url = object_url(this.member_class, :reorder, :method => :post) and
          can_edit?(first, first.position_column)
      end
      
      
      def standard_fields(*args)
        klass = args.first.is_a?(Class) ? args.shift : model
        extras = args
        
        fields = klass.attr_order.*.to_s & klass.content_columns.*.name

        fields -= %w{created_at updated_at created_on updated_on deleted_at} unless extras.include?(:include_timestamps)
        
        bt = extras.include?(:belongs_to)
        hm = extras.include?(:has_many)
        klass.reflections.values.map do |refl|
          fields << refl.name.to_s if bt && refl.macro == :belongs_to
          fields << refl.name.to_s if hm && refl.macro == :has_many
        end

        fields.reject! { |f| model.never_show? f }
        fields
      end
      
      
      def a_or_an(word)
        (word =~ /^[aeiou]/i ? "an " : "a ") + word
      end
            
    end
    
  end
  
end