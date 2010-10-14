# The Don't Repeat Yourself Markup Language
#
# Author::    Tom Locke (tom@tomlocke.com)
# Copyright:: Copyright (c) 2008
# License::   Distributes under the same terms as Ruby



# gem dependencies
require 'hobo_support'
require 'action_pack'

ActiveSupport::Dependencies.autoload_paths |= [ File.dirname(__FILE__)]

# The Don't Repeat Yourself Markup Language
module Dryml

    VERSION = File.read(File.expand_path('../../VERSION', __FILE__)).strip
    @@root = Pathname.new File.expand_path(File.dirname(__FILE__) + "/..")
    def self.root; @@root; end

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


    def precompile_taglibs
      Dir.chdir(Rails.root) do
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
      page_renderer(view, "#{controller_name}/#{EMPTY_PAGE}" )
    end

    def call_render(view, local_assigns, identifier)
      page_path = view.request.fullpath
      renderer = page_renderer(view, page_path, local_assigns.keys, identifier)
      this = view.controller.send(:dryml_context) || local_assigns[:this]
      view.instance_variable_set("@this", this)
      renderer.render_page(this, local_assigns).strip
    end


    def page_renderer(view, page_path, local_names=[], identifier=nil)

      prepare_view!(view)
      included_taglibs = ([APPLICATION_TAGLIB] + application_taglibs() + [subsite_taglib(page_path)] + controller_taglibs(view.controller.class)).compact

      if identifier.blank? && ! page_path.ends_with?(EMPTY_PAGE)
        opt = ActionController::Routing::Routes.recognize_path(page_path)
        identifier = view.view_paths.find( opt[:action],
                                           opt[:controller],
                                           false,
                                           view.lookup_context.instance_variable_get('@details')).identifier
      end
      if page_path.ends_with?(EMPTY_PAGE) || identifier.starts_with?('dryml-page-tag:')
        controller_class = view.controller.class
        @tag_page_renderer_classes[controller_class.name] ||=
          make_renderer_class("", page_path, local_names, DEFAULT_IMPORTS, included_taglibs)
        @tag_page_renderer_classes[controller_class.name].new(page_path, view)
      else
        mtime = File.mtime(identifier)
        renderer_class = @renderer_classes[page_path]

        # do we need to recompile?
        if (!renderer_class ||                                          # nothing cached?
            (local_names - renderer_class.compiled_local_names).any? || # any new local names?
            renderer_class.load_time < mtime)                           # cache out of date?
          renderer_class = make_renderer_class(File.read(identifier), identifier, local_names,
                                               DEFAULT_IMPORTS, included_taglibs)
          renderer_class.load_time = mtime
          @renderer_classes[page_path] = renderer_class
        end
        renderer_class.new(page_path, view)
      end
    end

    def controller_taglibs(controller_class)
      controller_class.try.included_taglibs || []
    end


    def subsite_taglib(page)
      parts = page.split("/")
      subsite = parts.length >= 3 ? parts[0..-3].join('_') : "front"
      src = "taglibs/#{subsite}_site"
      { :src => src } if Object.const_defined?(:Rails) && File.exists?("#{Rails.root}/app/views/#{src}.dryml")
    end

    def application_taglibs
      Dir.chdir(Rails.root) do
        Dir["app/views/taglibs/application/**/*.dryml"].map{|f| File.basename f, '.dryml'}.map do |n|
          { :src => "taglibs/application/#{n}" }
        end
      end
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
                    @request @ignore_missing_templates @_headers @variables_added
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
    #           uses [Hobo::Helper, Hobo::Helper::Translations,
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
                         path = if Object.const_defined?(:Rails) && FileTest.exists?("#{Rails.root}/config/dryml_static_tags.txt")
                                    "#{Rails.root}/config/dryml_static_tags.txt"
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

require 'dryml/railtie' if Object.const_defined?(:Rails)
