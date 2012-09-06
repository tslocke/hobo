# -*- coding: utf-8 -*-
require 'set'
require 'fileutils'

  module Dryml

    class DrymlGenerator

      HEADER = "<!-- AUTOMATICALLY GENERATED FILE - DO NOT EDIT -->\n\n"

      class << self
        attr_accessor :output_directory
      end

      def self.enable(generator_directories = [], output_directory = nil)
        @output_directory = output_directory
        @output_directory ||= "#{Rails.root}/app/views/taglibs/auto" if Object.const_defined?(:Rails)
        @generator_directories = generator_directories
      end

      def self.run(generator_directories=nil, output_directory=nil)
        @generator_directories ||= generator_directories
        @output_directory ||= output_directory
        @generator ||= new(generator_directories || @generator_directories)
        @generator.run
      end


      def initialize(generator_directories=nil)
        @templates = {}
        @digests   = {}
        generator_directories ||= Dryml::DrymlGenerator.generator_directories
        load_templates(generator_directories)
      end

      attr_accessor :subsite


      def load_templates(generator_directories)
        generator_directories.each do |path|
          dir = path.to_s
          Dir.glob("#{dir}/**/*.dryml.erb").each do |f|
            name = f[dir.length + 1..-11]
            erb = File.read(f)
            @templates[name] = ERB.new(erb, nil, '-').src
            # Create output directories and parents as required
            [nil, *Hobo.subsites].each do |s|
              FileUtils.mkdir_p(File.dirname("#{output_dir s}/#{name}"))
            end
          end
        end
      end


      def run
        # FIXME
        # Ensure all view hints loaded before running
        subsites = [nil]
        if defined?(:Hobo)
          Hobo::Model.all_models.*.view_hints
          subsites += [*Hobo.subsites]
        end

        subsites.each { |s| run_for_subsite(s) }
      end


      def run_for_subsite(subsite)
        self.subsite = subsite
        @templates.each_pair do |name, src|
          run_one(name, src)
        end
      end


      def output_dir(s=subsite)
        s ? "#{Dryml::DrymlGenerator.output_directory}/#{s}" : Dryml::DrymlGenerator.output_directory
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
        OpenSSL::Digest::SHA1.hexdigest(s)
      end


      # --- Helper methods for the templates --- #

      attr_reader :controller


      def controllers
        Hobo::Controller::Model.all_controllers(subsite).sort_by &:name
      end


      def models
        Hobo::Model.all_models.sort_by &:name
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

      # This method is used only to generate static default Model names in english only
      # it does not provide any translation
      # Localized apps will override the defaults by setting the specific keys in their locale files
      def model_name(*options)
        name = :plural.in?(options) ? model.model_name.human(:count=>2, :locale=>:en) : model.model_name.human(:locale=>:en)
        name = name.titleize.downcase                         if :lowercase.in?(options)
        name = name.camelize                                  if :camel.in?(options)
        name
      end

      # escape single quotes and backslashes for use in a single
      # quoted string
      def sq_escape(s)
        s.gsub(/[\\]/, "\\\\\\\\").gsub(/'/, "\\\\'")
      end


      def model_class
        model.name.underscore.gsub('_', '-').gsub('/', '--')
      end


      def view_hints
        model.view_hints
      end


      def through_collection_names(klass=model)
        klass.reflections.values.select do |refl|
          refl.macro == :has_many && refl.options[:through]
        end.map {|x| x.options[:through]}
      end


      def sortable_collection?(collection, model=self.model)
        # There's no perfect way to detect for this, given that acts_as_list
        # does not provide any metadata to reflect on, but if the :order
        # option is the same as the target classes position_column, that's a
        # pretty safe bet
        if defined? ActiveRecord::Acts::List::InstanceMethods
          refl = model.reflections[collection]
          klass = refl.klass
          klass < ActiveRecord::Acts::List::InstanceMethods &&
            klass.table_exists? &&
            klass.new.position_column == refl.options[:order].to_s
        end
      end


      def standard_fields(*args)
        klass = args.first.is_a?(Class) ? args.shift : model
        extras = args

        fields = klass.attr_order.*.to_s & (klass.table_exists? ? klass.content_columns.*.name : [])

        fields -= %w{created_at updated_at created_on updated_on deleted_at} unless extras.include?(:include_timestamps)

        bt = extras.include?(:belongs_to)
        hm = extras.include?(:has_many)
        klass.reflections.values.sort_by { |refl| refl.name.to_s }.map do |refl|
          fields << refl.name.to_s if bt && refl.macro == :belongs_to
          fields << refl.name.to_s if hm && refl.macro == :has_many && refl.options[:accessible]
        end

        fields.reject! { |f| model.never_show? f }
        fields
      end


      def creators
        defined?(model::Lifecycle) ? model::Lifecycle.publishable_creators : []
      end

      def transitions
        defined?(model::Lifecycle) ? model::Lifecycle.publishable_transitions : []
      end

      def creator_names
        creators.map { |c| c.name.to_s }
      end

      def transition_names
        transitions.map { |t| t.name.to_s }.uniq
      end


      def a_or_an(word)
        (word =~ /^[aeiou]/i ? "an " : "a ") + word
      end

    end

  end

