module Hobo::Dryml
  
  class DRYMLBuilder
    
    APPLICATION_TAGLIB = "hobolib/application"
    CORE_TAGLIB = "plugins/hobo/tags/core"

    def initialize(template_path)
      @build_instructions = Array.new
      @template_path      = template_path
      @part_names = []
    end


    def set_environment(environment)
      @environment = environment
    end


    def ready?(mtime)
      !(@build_instructions.empty? || @last_build_time.nil? || mtime > @last_build_time)
    end


    def clear_instructions
      @part_names.clear
      @build_instructions.clear
    end


    def add_build_instruction(type, params)
      @build_instructions << params.merge(:type => type)
    end
    
    def add_part(name, src, line_num)
      raise DrymlException.new("duplicate part: #{name}", @template_path, line_num) if name.in?(@part_names)
      add_build_instruction(:part, :src => src, :line_num => line_num)
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
           "; end + part_contexts_js; end")
    end


    def build(local_names, auto_taglibs)
      if auto_taglibs
        import_taglib(CORE_TAGLIB)
        import_taglib(APPLICATION_TAGLIB)
        Hobo::MappingTags.apply_standard_mappings(@environment)
      end
    
      @build_instructions.each do |instruction|
        name = instruction[:name]
        pred = instruction[:pred]
        case instruction[:type]
        when :def
          def_line = if pred
                       "defp :#{name}, (proc {|options| #{pred}}) do |__options__, __block__|"
                     elsif @environment.predicate_method?(name)
                       # Make sure we don't overwrite an existing predicate dispatcher
                       "defp :#{name} do |__options__, __block__|"
                     else
                       "def #{name}(__options__={}, template_procs, &__block__)"
                     end
          src = "#{def_line}; #{instruction[:method_body]}; end"
          @environment.class_eval(src, @template_path, instruction[:line_num])

        when :part
          @environment.class_eval(instruction[:src], @template_path, instruction[:line_num])
          
        when :render_page
          method_src = render_page_source(instruction[:src], local_names)
          @environment.compiled_local_names = local_names
          @environment.class_eval(method_src, @template_path, instruction[:line_num])
          
        when :include
          import_taglib(name, instruction[:as])
          
        when :module
          import_module(name.constantize, instruction[:as])
          
        when :set_theme
          set_theme(name)
          
        when :alias_method
          @environment.send(:alias_method, instruction[:new], instruction[:old])
          
        else
          raise HoboError.new("DRYML: Unknown build instruction type found when building #{@template_path}")
        end
      end
      @last_build_time = Time.now
    end
    

    def expand_template_path(path)
      base = if path.starts_with? "plugins"
               "vendor/" + path
             elsif path.include?("/")
               "app/views/#{path}"
             else
               template_dir = File.dirname(@template_path)
               "#{template_dir}/#{path}"
             end
       base + ".dryml"
    end


    def import_taglib(src_path, as=nil)
      path = expand_template_path(src_path)
      unless @template_path == path
        taglib = Taglib.get(RAILS_ROOT + (path.starts_with?("/") ? path : "/" + path))
        taglib.import_into(@environment, as)
      end
    end


    def import_module(mod, as=nil)
      raise NotImplementedError.new if as
      @environment.send(:include, mod)
    end
  

    def set_theme(name)
      if Hobo.current_theme.nil? or Hobo.current_theme == name
        Hobo.current_theme = name
        import_taglib("hobolib/themes/#{name}/application")
        mapping_module = "#{name}_mapping"
        if File.exists?(path = RAILS_ROOT + "/app/views/hobolib/themes/#{mapping_module}.rb")
          load(path)
          Hobo::MappingTags.apply_mappings(@environment)
        end
      end
    end
  end
end
