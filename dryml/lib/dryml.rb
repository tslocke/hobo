# The Don't Repeat Yourself Markup Language
#
# Author::    Tom Locke (tom@tomlocke.com)
# Copyright:: Copyright (c) 2008
# License::   Distributes under the same terms as Ruby

require 'hobo_support'
require 'action_pack'
require 'openssl'

ActiveSupport::Dependencies.autoload_paths |= [File.dirname(__FILE__)]
ActiveSupport::Dependencies.autoload_once_paths |= [File.dirname(__FILE__)]

# The Don't Repeat Yourself Markup Language
module Dryml

  VERSION = File.read(File.expand_path('../../VERSION', __FILE__)).strip
  @@root = Pathname.new File.expand_path('../..', __FILE__)
  def self.root; @@root; end
  EDIT_LINK_BASE = "https://github.com/Hobo/hobodoc/edit/master/dryml"

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
  ID_SEPARATOR = '; dryml-tag: '
  APPLICATION_TAGLIB = { :src => "taglibs/application" }
  CORE_TAGLIB        = { :src => "core", :plugin => "dryml" }
  @cache = {}
  extend self
  attr_accessor :last_if

  def precompile_taglibs
    Dir.chdir(Rails.root) do
      Dir["app/views/taglibs/**/*.dryml"].each do |f|
        Taglib.get(:template_dir => File.dirname(f), :src => File.basename(f).remove(".dryml"), :source_template => "_.dryml")
      end
    end
  end

  def clear_cache
    @cache = {}
  end

  def render_tag(view, tag, options={})
    renderer = empty_page_renderer(view)
    renderer.render_tag(tag, options)
  end

  def empty_page_renderer(view)
    page_renderer(view, page_tag_identifier(view.controller.controller_path))
  end

  def page_tag_identifier(controller_path, tag_name='')
    "controller: #{controller_path}#{ID_SEPARATOR}#{tag_name}"
  end

  def call_render(view, local_assigns, identifier)
    this = view.controller.send(:dryml_context) || local_assigns[:this]
    view.instance_variable_set("@this", this)
    # do this last, as TemplateEnvironment copies instance variables in initalize
    renderer = page_renderer(view, identifier, local_assigns.keys)
    if identifier =~ /#{ID_SEPARATOR}/
      tag_name = identifier.split(ID_SEPARATOR).last
      renderer.render_tag(tag_name, {:with => this} )
    else
      renderer.render_page(this, local_assigns).strip
    end
  end

  def imports_for_view(view)
    imports = []
    imports << Sprockets::Rails::Helper if defined?(Sprockets) && defined?(Rails)
    imports << ActionView::Helpers if defined?(ActionView)
    imports + view.controller.class.modules_for_helpers(view.controller.class.all_helpers_from_path(view.controller.class.helpers_path))
  end

  def page_renderer(view, identifier, local_names=[], controller_path=nil, imports=nil)
    controller_path ||= view.controller.controller_path
    if identifier =~ /#{ID_SEPARATOR}/
      identifier = identifier.split(ID_SEPARATOR).first
      @cache[identifier] ||=  make_renderer_class("", "", local_names, taglibs_for(controller_path), imports_for_view(view))
      @cache[identifier].new(view)
    else
      mtime = File.mtime(identifier)
      renderer_class = @cache[identifier]
      # do we need to recompile?
      if (!renderer_class ||                                          # nothing cached?
          (local_names - renderer_class.compiled_local_names).any? || # any new local names?
          renderer_class.load_time < mtime)                           # cache out of date?
        renderer_class = make_renderer_class(File.read(identifier), identifier,
                                             local_names, taglibs_for(controller_path),
                                             imports_for_view(view))
        renderer_class.load_time = mtime
        @cache[identifier] = renderer_class
      end
      renderer_class.new(view)
    end
  end

  def get_field(object, field)
    return nil if object.nil?
    field_str = field.to_s
    case
    when object.respond_to?(field_str)
      object.send(field_str)
    when field_str =~ /^\d+$/
      object[field.to_i]
    else
      object[field]
    end
  end

  def get_field_path(object, path)
    return nil if object.nil?
    path = path.is_a?(String) ? path.split('.') : Array(path)
    parent = nil
    path.each do |field|
      parent = object
      object = get_field(parent, field)
    end
    [parent, path.last, object]
  end

  def unreserve(word)
    word = word.to_s
    word += '_' if RESERVED_WORDS.include?(word)
    word
  end

  def static_tags
    @static_tags ||= begin
                       path = if Object.const_defined?(:Rails) && FileTest.exists?("#{Rails.root}/config/dryml_static_tags.txt")
                                  "#{Rails.root}/config/dryml_static_tags.txt"
                              else
                                  File.join(File.dirname(__FILE__), "dryml/static_tags")
                              end
                       File.read(path).split
                     end
  end

  attr_writer :static_tags

  # FIXME: This helper seems to be useless, since it does need Rails,
  # and with Rails it is useless since Dryml does not need Hobo
  #
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
  # @param [Array] A list of helper modules to import.  For example,
  #                     [ActionView::Base]
  def render(template_src, locals={}, template_path=nil, included_taglibs=[], view=nil, imports=nil)
    template_path ||= template_src
    view ||= ActionView::Base.new(ActionController::Base.view_paths, {})
    this = locals.delete(:this) || nil

    renderer_class = Dryml::Template.build_cache[template_path]._?.environment ||
      make_renderer_class(template_src, template_path, locals.keys, included_taglibs, imports)
    renderer_class.new(view).render_page(this, locals)
  end

private

  def taglibs_for(controller_path)
    ( subsite_taglibs(controller_path) +
      ((controller_path.camelize+"Controller").constantize.try.included_taglibs||[])
    ).compact
  end

  def subsite_taglibs(controller_path)
    parts = controller_path.split("/")
    subsite = parts.length >= 2 ? parts[0..-2].join('_') : "front"
    src = "taglibs/#{subsite}_site"
    Object.const_defined?(:Rails) && File.exists?("#{Rails.root}/app/views/#{src}.dryml") ?
      taglibs_in_dir("#{subsite}_site").unshift({ :src => src }) : [APPLICATION_TAGLIB]
  end

  def taglibs_in_dir(dir_name)
    Dir.chdir(Rails.root) do
      Dir["app/views/taglibs/#{dir_name}/**/*.dryml"].map{|f| File.basename f, '.dryml'}.map do |n|
        { :src => "taglibs/#{dir_name}/#{n}" }
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
  def make_renderer_class(template_src, template_path, locals=[], taglibs=[], imports=nil)
    renderer_class = Class.new(TemplateEnvironment)
    compile_renderer_class(renderer_class, template_src, template_path, locals, taglibs, imports)
    renderer_class
  end

  def compile_renderer_class(renderer_class, template_src, template_path, locals, taglibs=[], imports=nil)
    template = Dryml::Template.new(template_src, renderer_class, template_path)

    imports.each {|m| template.import_module(m)} if imports

    # the sum of all the names we've seen so far - eventually we'll be ready for all of 'em
    all_local_names = renderer_class.compiled_local_names | locals

    template.compile(all_local_names, [CORE_TAGLIB]+taglibs)
  end

end

require 'dryml/dryml_builder'
require 'dryml/dryml_doc'
require 'dryml/dryml_generator'
require 'dryml/helper'
require 'dryml/parser'
require 'dryml/part_context'
require 'dryml/scoped_variables'
require 'dryml/tag_parameters'
require 'dryml/taglib'
require 'dryml/template'
require 'dryml/template_environment'
require 'dryml/extensions/action_controller/dryml_methods'
require 'dryml/parser/attribute'
require 'dryml/parser/base_parser'
require 'dryml/parser/document'
require 'dryml/parser/element'
require 'dryml/parser/elements'
require 'dryml/parser/source'
require 'dryml/parser/text'
require 'dryml/parser/tree_parser'

require 'dryml/railtie' if defined?(Rails)
