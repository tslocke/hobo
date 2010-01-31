module Dryml

  class DRYMLBuilder

    def initialize(template)
      @template = template
      @build_instructions = nil # set to [] on the first add_build_instruction
      @part_names = []
    end

    attr_reader :template, :environment

    def template_path
      template.template_path
    end


    def set_environment(environment)
      @environment = environment
    end


    def ready?(mtime, d=false)
      @build_instructions && @last_build_mtime && @last_build_mtime >= mtime
    end


    def start
      @part_names.clear
      @build_instructions = []
    end


    def add_build_instruction(type, params)
      @build_instructions << params.merge(:type => type)
    end


    def add_part(name, src, line_num)
      raise DrymlException.new("duplicate part: #{name}", template_path, line_num) if name.in?(@part_names)
      add_build_instruction(:def, :src => src, :line_num => line_num)
      @part_names << name
    end


    def <<(params)
      @build_instructions << params
    end


    def render_page_source(src, local_names)
      locals = local_names.map{|l| "#{l} = __local_assigns__[:#{l}];"}.join(' ')

      ("def render_page(__page_this__, __local_assigns__); " +
            "#{locals} new_object_context(__page_this__) do " +
            src +
           "; output_buffer; end; end")
    end


    def erb_process(erb_src, method_def=false)
      trim_mode = ActionView::TemplateHandlers::ERB.erb_trim_mode
      erb = ERB.new(erb_src, nil, trim_mode, "output_buffer")
      src = erb.src.split(';')[1..-2].join(';')
      
      if method_def
        src.sub /^\s*def.*?\(.*?\)/, '\0 __in_erb_template=true; '
      else
        "__in_erb_template=true; " + src
      end
    end


    def build(local_names, auto_taglibs, src_mtime)

      auto_taglibs.each { |t| import_taglib(t) }

      @build_instructions._?.each do |instruction|
        name = instruction[:name]
        case instruction[:type]
        when :eval
          @environment.class_eval(instruction[:src], template_path, instruction[:line_num])

        when :def
          src = erb_process(instruction[:src], true)
          @environment.class_eval(src, template_path, instruction[:line_num])

        when :render_page
          method_src = render_page_source(erb_process(instruction[:src]), local_names)
          @environment.compiled_local_names = local_names
          @environment.class_eval(method_src, template_path, instruction[:line_num])

        when :include
          import_taglib(instruction)

        when :module
          import_module(name.constantize, instruction[:as])

        when :set_theme
          set_theme(name)

        when :alias_method
          @environment.send(:alias_method, instruction[:new], instruction[:old])

        else
          raise RuntimeError.new("DRYML: Unknown build instruction :#{instruction[:type]}, " +
                                 "building #{template_path}")
        end
      end
      @last_build_mtime = src_mtime
    end


    def import_taglib(options)
      if options[:module]
        import_module(options[:module].constantize, options[:as])
      else
        template_dir = File.dirname(template_path)
        options = options.merge(:template_dir => template_dir)

        taglib = Taglib.get(options)
        taglib.import_into(@environment, options[:as])
      end
    end


    def import_module(mod, as=nil)
      raise NotImplementedError if as
      @environment.send(:include, mod)
    end


    def set_theme(name)
      if Hobo.current_theme.nil? or Hobo.current_theme == name
        Hobo.current_theme = name
        import_taglib(:src => "taglibs/themes/#{name}/#{name}")
      end
    end
  end
end
