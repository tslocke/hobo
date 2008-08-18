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
      
      
      def load_templates
        Dir["#{TEMPLATES}/**/*.erb.dryml"].each do |f|
          name = f[TEMPLATES.length + 1..-11]
          erb = File.read(f)
          @templates[name] = ERB.new(erb, nil, '-').src
          
          # Create output directory and parents if required
          FileUtils.mkdir_p(File.dirname("#{OUTPUT}/#{name}"))
        end
      end
      
      
      def run
        now = Time.now
        @templates.each_pair do |name, src|
          run_one(name, src)
        end
        puts "DRYML Generator took #{Time.now - now}s"
      end
      
      
      def run_one(name, src)
        dryml = instance_eval(src)
        if dryml_changed?(name, dryml)
          out = HEADER + dryml
          File.open("#{OUTPUT}/#{name}.dryml", 'w') { |f| f.write(out) }
        end
      end
      
      
      def dryml_changed?(name, dryml)
        d = digest dryml
        if d != @digests[name]
          @digests[name] = d
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
    
      def each_model
        Hobo::ModelController.all_controllers(subsite).each do |controller|
          @controller = controller
          yield
        end
      end
      
      
      def model
        @controller.model
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
      
      
      def standard_fields(klass=model, include_timestamps=false)
        fields = klass.attr_order.*.to_s & klass.content_columns.*.name
        fields -= %w{created_at updated_at created_on updated_on deleted_at} unless include_timestamps
        fields.reject! { |f| model.never_show? f }
        fields
      end
      
      
    end
    
  end
  
end