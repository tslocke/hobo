module Hobo::Dryml
  
  class DRYMLBuilder

    def initialize(template_path)
      @template_path = template_path
      @build_instructions = Array.new
      @part_names = []
    end
    
    attr_reader :template_path


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
      raise DrymlException.new("duplicate part: #{name}", template_path, line_num) if name.in?(@part_names)
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
           "; _erbout; end + part_contexts_storage_tag; end")
    end
    
    
    def erb_process(erb_src)
      # Strip off "_erbout = ''" from the beginning and "; _erbout"
      # from the end, because we do things differently around
      # here. (_erbout is defined as a method)
      ERB.new(erb_src, nil, ActionView::Base.erb_trim_mode).src[("_erbout = '';").length..-("; _erbout".length)]
    end


    def build(local_names, auto_taglibs)

      auto_taglibs.each{|t| import_taglib(t)}
    
      @build_instructions.each do |instruction|
        name = instruction[:name]
        case instruction[:type]
        when :def
          # puts instruction[:src] + "\n\n"
          src = erb_process(instruction[:src])
          @environment.class_eval(src, template_path, instruction[:line_num])
          
        when :part
          @environment.class_eval(erb_process(instruction[:src]), template_path, instruction[:line_num])
          
        when :render_page
          # puts instruction[:src]
          method_src = render_page_source(erb_process(instruction[:src]), local_names)
          @environment.compiled_local_names = local_names
          @environment.class_eval(method_src, template_path, instruction[:line_num])
          
        when :include
          import_taglib(name, instruction[:as])
          
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
      @last_build_time = Time.now
    end
    

    def expand_template_path(path)
      base = if path.starts_with? "plugins"
               "vendor/" + path
             elsif path.include?("/")
               "app/views/#{path}"
             else
               template_dir = File.dirname(template_path)
               "#{template_dir}/#{path}"
             end
       base + ".dryml"
    end


    def import_taglib(src_path, as=nil)
      path = expand_template_path(src_path)
      unless template_path == path
        taglib = Taglib.get(RAILS_ROOT + (path.starts_with?("/") ? path : "/" + path))
        taglib.import_into(@environment, as)
      end
    end


    def import_module(mod, as=nil)
      raise NotImplementedError if as
      @environment.send(:include, mod)
    end
  

    def set_theme(name)
      if Hobo.current_theme.nil? or Hobo.current_theme == name
        Hobo.current_theme = name
        import_taglib("taglibs/themes/#{name}/application")
      end
    end
  end
end
