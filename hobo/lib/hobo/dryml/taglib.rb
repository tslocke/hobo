module Hobo::Dryml

  class Taglib

    @cache = {}

    class << self

      def get(options)
        raise DrymlException, "No such taglib: #{path}" unless File.exists?(path)
        file = taglib_file(options)

        taglib = @cache[options]
        if taglib
          taglib.reload
        else
          taglib = Taglib.new(file, renames)
          @cache[options] = taglib
        end
        taglib
      end
      
      def clear_cache
        @cache = {}
      end
      
      private
      
      def taglib_file(options)
        if (plugin = options[:bundle])
          base = "vendor/plugins/#{plugin}/taglibs"
        elsif (bundle = options[:bundle])
          
        else
      elsif path.include?("/")
               "app/views/#{path}"
             else
               template_dir = File.dirname(template_path)
               "#{template_dir}/#{path}"
             end
       base + ".dryml"
      RAILS_ROOT + (path.starts_with?("/") ? path : "/" + path), options[:renames]

        
        File.new(path)
      end

    end

    def initialize(file, renames)
      @file = file
      @renames = renames
      load
    end

    def reload
      load if @file.mtime > @last_load_time
    end

    def load
      @module = Module.new do
        
        @tag_attrs = {}
        @tag_aliases = {}
        
        class << self
          
          def included(base)
            @tag_aliases.each do |tag, feature|
              base.send(:alias_method_chain, tag, feature)
            end
          end

          def _register_tag_attrs(tag, attrs)
            @tag_attrs[tag] = attrs
          end
          attr_reader :tag_attrs
          
          def delayed_alias_method_chain(tag, feature)
            @tag_aliases[tag] = feature
          end
          
        end
        
      end
      @file.rewind
      template = Template.new(@file.read, @module, @file.path, @renamess)
      template.compile([], [])
      @last_load_time = @file.mtime
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
