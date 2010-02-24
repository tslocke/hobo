# The Don't Repeat Yourself Markup Language
#
# Author::    Tom Locke (tom@tomlocke.com)
# Copyright:: Copyright (c) 2008
# License::   Distributes under the same terms as Ruby



# gem dependencies
require 'hobosupport'
require 'action_pack'
require 'active_record' if ActionPack::VERSION::MAJOR==2 && ActionPack::VERSION::MINOR==2

ActiveSupport::Dependencies.load_paths |= [ File.dirname(__FILE__)] if ActiveSupport.const_defined? :Dependencies

# Hobo can be installed in /vendor/hobo, /vendor/plugins/hobo, vendor/plugins/hobo/hobo, etc.
::DRYML_ROOT = File.expand_path(File.dirname(__FILE__) + "/..")

# The Don't Repeat Yourself Markup Language
module Dryml

    VERSION = "1.1.0.pre0"

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
    CORE_TAGLIB        = { :src => "core", :plugin => "dryml" }

    DEFAULT_IMPORTS = defined?(ApplicationHelper) ? [ApplicationHelper] : []

    @renderer_classes = {}
    @tag_page_renderer_classes = {}

    extend self

    attr_accessor :last_if
    
    def enable(generator_directories=[], output_directory=".")
      ActionView::Template.register_template_handler("dryml", Dryml::TemplateHandler)
      if ActionView::Template.respond_to? :exempt_from_layout
        ActionView::Template.exempt_from_layout('dryml')
      elsif
        ActionView::Base.exempt_from_layout('dryml')
      end
      DrymlGenerator.enable(generator_directories, output_directory)
    end
    
    
    def precompile_taglibs
      Dir.chdir(RAILS_ROOT) do
        taglibs = Dir["vendor/plugins/**/taglibs/**/*.dryml"] + Dir["app/views/taglibs/**/*.dryml"]
        taglibs.each do |f|
          Dryml::Taglib.get(:template_dir => File.dirname(f), :src => File.basename(f).remove(".dryml"))
        end
      end
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
      included_taglibs = ([APPLICATION_TAGLIB, subsite_taglib(page)] + controller_taglibs(view.controller.class)).compact

      if page.ends_with?(EMPTY_PAGE)
        # DELETE ME: controller_class = controller_class_for(page)
        controller_class = view.controller.class
        @tag_page_renderer_classes[controller_class.name] ||=
          make_renderer_class("", page, local_names, DEFAULT_IMPORTS, included_taglibs)
        @tag_page_renderer_classes[controller_class.name].new(page, view)
      else        
        filename ||= if view.view_paths.respond_to? :find_template
                       # Rails 2.3
                       view.view_paths.find_template(page + ".dryml").filename
                     else
                       # Rails 2.2
                       view._pick_template(page + ".dryml").filename
                     end
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
      { :src => src } if Object.const_defined?(:RAILS_ROOT) && File.exists?("#{RAILS_ROOT}/app/views/#{src}.dryml")
    end

    def get_field(object, field)
      return nil if object.nil?
      field_str = field.to_s
      begin
        return object.send(field_str)
      rescue NoMethodError => ex
        if field_str =~ /^\d+$/
          return object[field.to_i]
        else
          return object[field]
        end
      end
    end


    def get_field_path(object, path)
      path = if path.is_a? String
               path.split('.')
             else
               Array(path)
             end

      parent = nil
      path.each do |field|
        return nil if object.nil?
        parent = object
        object = get_field(parent, field)
      end
      [parent, path.last, object]
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

    # create and compile a renderer class (AKA Dryml::Template::Environment)
    #
    # template_src:: the DRYML source
    # template_path:: the filename of the source.  This is used for
    #                 caching
    # locals:: local variables.
    # imports:: A list of helper modules to import.  For example, Hobo
    #           uses [Hobo::HoboHelper, Hobo::Translations,
    #           ApplicationHelper] 
    # included_taglibs:: A list of Taglibs to include. { :src =>
    #                    "core", :plugin => "dryml" } is automatically
    #                    added to this list.
    #
    def make_renderer_class(template_src, template_path, locals=[], imports=[], included_taglibs=[])
      renderer_class = Class.new(TemplateEnvironment)
      compile_renderer_class(renderer_class, template_src, template_path, locals, imports, included_taglibs)
      renderer_class
    end


    def compile_renderer_class(renderer_class, template_src, template_path, locals, imports, included_taglibs=[])
      template = Dryml::Template.new(template_src, renderer_class, template_path)
      imports.each {|m| template.import_module(m)}

      taglibs = [CORE_TAGLIB] + included_taglibs

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


    def static_tags
      @static_tags ||= begin
                         path = if Object.const_defined?(:RAILS_ROOT) && FileTest.exists?("#{RAILS_ROOT}/config/dryml_static_tags.txt")
                                    "#{RAILS_ROOT}/config/dryml_static_tags.txt"
                                else
                                    File.join(File.dirname(__FILE__), "dryml/static_tags")
                                end
                         File.readlines(path).*.chop
                       end
    end

    attr_writer :static_tags

    # Helper function for use outside Hobo/Rails
    #
    # Pass the template context in locals[:this]
    #
    # This function caches.  If the mtime of template_path is older
    # than the last compilation time, the cached version will be
    # used.  If no template_path is given, template_src is used as the
    # key to the cache.
    #
    # If a local variable is not present when the template is
    # compiled, it will be ignored when the template is used.  In
    # other words, the variable values may change, but the names may
    # not.
    #
    # included_taglibs is only used during template compilation.
    #
    # @param [String] template_src the DRYML source
    # @param [Hash] locals local variables.
    # @param [String, nil] template_path the filename of the source.  
    # @param [Array] included_taglibs A list of Taglibs to include. { :src =>
    #                    "core", :plugin => "dryml" } is automatically
    #                    added to this list.
    # @param [ActionView::Base] view an ActionView instance    
    def render(template_src, locals={}, template_path=nil, included_taglibs=[], view=nil)
      template_path ||= template_src
      view ||= ActionView::Base.new(ActionController::Base.view_paths, {})
      this = locals.delete(:this) || nil

      renderer_class = Dryml::Template.build_cache[template_path]._?.environment ||
        Dryml.make_renderer_class(template_src, template_path, locals.keys)
      renderer_class.new(template_path, view).render_page(this, locals)      
    end
    
end
