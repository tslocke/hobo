module Hobo::Dryml

  class DrymlException < Exception; end

  TagDef = Struct.new "TagDef", :name, :attrs, :proc

  RESERVED_WORDS = %w{if for while do class else elsif unless case when module in}

  EMPTY_PAGE = "[tag-page]"

  @page_environments = {}

  class << self

    attr_accessor :last_if

    def render_tag(view, tag, options={})
      renderer = empty_page_renderer(view)
      renderer.render_tag(tag, options)
    end


    def empty_page_renderer(view)
      page_renderer(view, [], EMPTY_PAGE)
    end


    def page_renderer(view, local_names=[], page=nil)
      prepare_view!(view)
      if page === EMPTY_PAGE
        @tag_page_renderer_class =  make_renderer_class("", EMPTY_PAGE, local_names, [ApplicationHelper]) if
          @tag_page_renderer_class.nil? or RAILS_ENV == "development"
        @tag_page_renderer_class.new(page, view)
      else
        page ||= view.instance_variable_get('@hobo_template_path')
        template_path = "app/views/" + page + ".dryml"
        src_file = File.new(File.join(RAILS_ROOT, template_path))
        renderer_class = @page_environments[page]

        # do we need to recompile?
        if (!renderer_class or                                          # nothing cahced?
            (local_names - renderer_class.compiled_local_names).any? or # any new local names?
            renderer_class.load_time < src_file.mtime or                # cache out of date?
            RAILS_ENV == "development")                                 # always reload if in dev mode
          renderer_class = make_renderer_class(src_file.read, template_path, local_names,
                                               default_imports_for_view(view))
          renderer_class.load_time = src_file.mtime
          @page_environments[page] = renderer_class
        end
        renderer_class.new(page, view)
      end
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

    def default_imports_for_view(view)
      [ApplicationHelper,
       view.controller.class.name.sub(/Controller$/, "Helper").constantize]
    end

    def make_renderer_class(template_src, template_path, locals, imports)
      renderer_class = Class.new(TemplateEnvironment)
      compile_renderer_class(renderer_class, template_src, template_path, locals, imports)
      renderer_class
    end

    def compile_renderer_class(renderer_class, template_src, template_path, locals, imports)
      template = Template.new(template_src, renderer_class, template_path)
      imports.each {|m| template.import_module(m)}

      # the sum of all the names we've seen so far - eventually we'll be ready for all of 'em
      all_local_names = renderer_class.compiled_local_names | locals

      template.compile(all_local_names)
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
