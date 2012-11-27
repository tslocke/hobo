  module Dryml

    class Taglib

      @cache = {}

      class << self

        def get(options)
          taglib_filenames(options).map do |src_file|
            taglib = @cache[src_file]
            if taglib
              taglib.reload
            else
              taglib = Taglib.new(src_file)
              @cache[src_file] = taglib
            end
            taglib
          end
        end

        def clear_cache
          @cache = {}
        end

        private

        # Requirements for  hobo-plugin for loading a taglib when the plugin is loaded as a gem:
        # - the plugin must define the <gem_name>.camelize.constantize.root() method
        # - the root() method must return a Pathname object (like Hobo.root, Dryml.root, Rails.root, etc.)
        # - the taglibs must be available in the 'taglibs' dir in the gem root
        # You can include the taglib with <include gem='gem_name'/> if the taglib name has the same gem name.
        # If the plugin defines different taglibs you must also specify the src attribute of the taglib that you want
        # to include: <include gem='gem_name' src='taglib_name'/>'

        def taglib_filenames(options)
          plugin       = options[:plugin]
          gem          = options[:gem]
          app_root     = Rails.root if Object.const_defined?(:Rails)
          app_root   ||= Pathname.new(File.expand_path('.'))
          search_path  = []
          search_path << Dryml.root.join('taglibs') if plugin == 'dryml'
          search_path << Hobo.root.join('lib/hobo/rapid/taglibs') if plugin == 'hobo' || gem == 'hobo'
          search_path << app_root.join('vendor/plugins', plugin, 'taglibs') if !plugin.blank?
          search_path << gem.tr('-','_').camelize.constantize.root.join('taglibs') if !gem.blank?
          search_path << app_root.join('app/views') if options[:src] =~ /\//
          search_path << Pathname.new(options[:absolute_template_path]) if options[:absolute_template_path]
          search_path << Pathname.new(options[:template_dir]) if options[:template_dir] =~ /^\//
          search_path << app_root.join(options[:template_dir].gsub(/^\//, ''))
          src          = options[:src] || gem || plugin
          results = nil
          search_path.any? {|path| !(results = Dir[path.join "#{src}.dryml"]).empty?}
          raise DrymlException, "No such taglib: #{src} #{options.inspect}" if results.empty?
          results - [File.expand_path(options[:source_template])]

        end

      end

      def initialize(src_file)
        @src_file = src_file
        load
      end

      def reload
        load if File.mtime(@src_file) > @last_load_time
      end

      def load
        @module = Module.new do

          @tag_attrs = {}
          @tag_aliases = []

          class << self

            def included(base)
              @tag_aliases.each do |tag, feature|
                if base.respond_to? :alias_method_chain_on_include
                  base.alias_method_chain_on_include tag, feature
                else
                  base.send(:alias_method_chain, tag, feature)
                end
              end
            end

            def _register_tag_attrs(tag, attrs)
              @tag_attrs[tag] = attrs
            end
            attr_reader :tag_attrs

            def alias_method_chain_on_include(tag, feature)
              @tag_aliases << [tag, feature]
            end

          end

        end
        template = Template.new(File.read(@src_file), @module, @src_file)
        template.compile([], [])
        @last_load_time = File.mtime(@src_file)
      end

      def import_into(class_or_module, as)
        if as
          # Define a method on class_or_module named whatever 'as'
          # is. The first time the method is called it creates and
          # returns an object that provides the taglib's tags as
          # methods. On subsequent calls the object is cached in an
          # instance variable "@_#{as}_taglib"

          taglib_module = @module
          ivar = "@_#{as}_taglib"
          class_or_module.send(:define_method, as) do
            instance_variable_get(ivar) or begin
                                             as_class = Class.new(TemplateEnvironment) { include taglib_module }
                                             as_object = as_class.new
                                             as_object.copy_instance_variables_from(self)
                                             instance_variable_set(ivar, as_object)
                                           end
          end
        else
          class_or_module.send(:include, @module)
          class_or_module.tag_attrs.update(@module.tag_attrs) if @module.respond_to?(:tag_attrs)
        end
      end

    end

  end
