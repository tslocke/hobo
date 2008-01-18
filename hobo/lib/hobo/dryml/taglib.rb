module Hobo
  
  module Dryml

    class Taglib
     
      @cache = {}
     
      class << self
     
        def get(options)
          taglib = @cache[options]
          if taglib
            taglib.reload
          else
            src_file = taglib_filename(options)
            renames = (bundle = options[:bundle] and
                       Bundle.bundles[bundle]._?.renames)
     
            taglib = Taglib.new(src_file, renames)
            @cache[options] = taglib
          end
          taglib
        end
        
        def clear_cache
          @cache = {}
        end
        
        private
        
        def taglib_filename(options)
          base = if (plugin = options[:plugin])
                   "vendor/plugins/#{plugin}/taglibs"
                 elsif (bundle_name = options[:bundle])
                   bundle = Bundle.bundles[bundle_name]
                   "vendor/plugins/#{bundle.plugin}/taglibs"
                 elsif options[:src] =~ /\//
                   "app/views"
                 else
                   options[:template_dir].gsub(/^\//, "") # remove leading / if there is one
                 end
          
          filename = "#{RAILS_ROOT}/#{base}/#{options[:src]}.dryml"
          raise DrymlException, "No such taglib: #{options.inspect} #{filename}" unless File.exists?(filename)
          filename
        end
     
      end
     
      def initialize(src_file, renames)
        @src_file = src_file
        @renames = renames
        load
      end
     
      def reload
        load if File.mtime(@src_file) > @last_load_time
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
        template = Template.new(File.read(@src_file), @module, @src_file, @renames)
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
  
end
