module Hobo::Dryml

  class Taglib

    @cache = {}

    class << self

      def get(path)
        raise DrymlException.new("No such taglib: #{path}") unless File.exists?(path)
        file = File.new(path)

        taglib = @cache[file.path]
        if taglib
          taglib.reload
        else
          taglib = Taglib.new(file)
          @cache[file.path] = taglib
        end
        taglib
      end
      
      def clear_cache
        @cache = {}
      end

    end

    def initialize(file)
      @file = file
      load
    end

    def reload
      load if @file.mtime > @last_load_time
    end

    def load
      @module = Module.new
      @module.extend(TagModule)
      @file.rewind
      template = Template.new(@file.read, @module, @file.path)
      template.compile([], false)
      @last_load_time = @file.mtime
    end

    def import_into(class_or_module, as)
      if as
        raise NotImplementedError.new
        as_class = Class.new(TemplateEnvironment) { include @module }
        class_or_module.send(:define_method, as) { @module }
      else
        class_or_module.send(:include, @module)
      end
    end

  end
end
