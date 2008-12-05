module Hobo

  module Dryml

    class DrymlSyntaxError < RuntimeError; end

    class DrymlException < Exception
      def initialize(message, path=nil, line_num=nil)
        if path && line_num
          super(message + " -- at #{path}:#{line_num}")
        else
          super(message)
        end
      end
    end

    TagDef = Struct.new "TagDef", :name, :attrs, :proc

    RESERVED_WORDS = %w{if for while do class else elsif unless case when module in}

    EMPTY_PAGE = "[tag-page]"

    APPLICATION_TAGLIB = { :src => "taglibs/application" }
    CORE_TAGLIB        = { :src => "core", :plugin => "hobo" }

    DEFAULT_IMPORTS = (if defined?(ApplicationHelper)
                         [Hobo::HoboHelper, ApplicationHelper]
                       else
                         [Hobo::HoboHelper]
                       end)

    @renderer_classes = {}
    @tag_page_renderer_classes = {}

    extend self

    attr_accessor :last_if
    
    def enable
      ActionView::Template.register_template_handler("dryml", Hobo::Dryml::TemplateHandler)
    end
    

    def clear_cache
      @renderer_classes = {}
      @tag_page_renderer_classes = {}
    end

    def render_tag(view, tag, options={})
      renderer = empty_page_renderer(view)
      renderer.render_tag(tag, options)
    end


    def empty_page_renderer(view)
      controller_name = view.controller.class.name.underscore.sub(/_controller$/, "")
      page_renderer(view, [], "#{controller_name}/#{EMPTY_PAGE}")
    end


    def page_renderer_for_template(view, local_names, template)
      page_renderer(view, local_names, template.path_without_extension, template.filename)
    end


    def page_renderer(view, local_names=[], page=nil, filename=nil)
      if RAILS_ENV == "development"
        clear_cache
        Taglib.clear_cache
      end

      prepare_view!(view)
      included_taglibs = ([subsite_taglib(page)] + controller_taglibs(view.controller.class)).compact

      if page.ends_with?(EMPTY_PAGE)
        # DELETE ME: controller_class = controller_class_for(page)
        controller_class = view.controller.class
        @tag_page_renderer_classes[controller_class.name] ||=
          make_renderer_class("", page, local_names, DEFAULT_IMPORTS, included_taglibs)
        @tag_page_renderer_classes[controller_class.name].new(page, view)
      else
        filename ||= view._pick_template(page + ".dryml").filename
        mtime = File.mtime(filename)
        renderer_class = @renderer_classes[page]

        # do we need to recompile?
        if (!renderer_class ||                                          # nothing cached?
            (local_names - renderer_class.compiled_local_names).any? || # any new local names?
            renderer_class.load_time < mtime)                           # cache out of date?
          renderer_class = make_renderer_class(File.read(filename), filename, local_names,
                                               DEFAULT_IMPORTS, included_taglibs)
          renderer_class.load_time = mtime
          @renderer_classes[page] = renderer_class
        end
        renderer_class.new(page, view)
      end
    end


    # TODO: Delete this - not needed (use view.controller.class)
    def controller_class_for(page)
      controller, view = Controller.controller_and_view_for(page)
      "#{controller.camelize}Controller".constantize
    end


    def controller_taglibs(controller_class)
      controller_class.try.included_taglibs || []
    end


    def subsite_taglib(page)
      parts = page.split("/")
      subsite = parts.length >= 3 ? parts[0..-3].join('_') : "front"
      src = "taglibs/#{subsite}_site"
      { :src => src } if File.exists?("#{RAILS_ROOT}/app/views/#{src}.dryml")
    end


    def prepare_view!(view)
      # Not sure why this isn't done for me...
      # There's probably a button to press round here somewhere
      for var in %w(@flash @cookies @action_name @_session @_request @request_origin
                    @template @request @ignore_missing_templates @_headers @variables_added
                    @_flash @response @template_class
                    @_cookies @before_filter_chain_aborted @url
                    @_response @template_root @headers @_params @params @session)
        unless @view.instance_variables.include?(var)
          view.instance_variable_set(var, view.controller.instance_variable_get(var))
        end
      end
    end


    def make_renderer_class(template_src, template_path, locals, imports, included_taglibs=[])
      renderer_class = Class.new(TemplateEnvironment)
      compile_renderer_class(renderer_class, template_src, template_path, locals, imports, included_taglibs)
      renderer_class
    end


    def compile_renderer_class(renderer_class, template_src, template_path, locals, imports, included_taglibs=[])
      template = Dryml::Template.new(template_src, renderer_class, template_path)
      imports.each {|m| template.import_module(m)}

      taglibs = [CORE_TAGLIB, APPLICATION_TAGLIB] + included_taglibs

      # the sum of all the names we've seen so far - eventually we'll be ready for all of 'em
      all_local_names = renderer_class.compiled_local_names | locals

      template.compile(all_local_names, taglibs)
    end


    def unreserve(word)
      word = word.to_s
      if RESERVED_WORDS.include?(word)
        word + "_"
      else
        word
      end
    end

  end

end
