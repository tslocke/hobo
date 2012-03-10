require 'bundler/cli'
module Hobo
  class PluginGenerator < Rails::Generators::Base
    source_root File.expand_path('../templates', __FILE__)

    include Generators::Hobo::Plugin

    desc "This generator creates a hobo plugin and optionally installs it.  Takes as its argument the directory where to create the plugin.   Absolute paths are recommended.   The last element on the path is used as the plugin name."
    argument :name, :banner => "PATHNAME"
    class_option :subsite, :type => :string, :aliases => '-e', :desc => "subsite; If supplied, the plugin is installed in the current app to the specified subsite.  The most common subsite names are 'front' and 'admin'."

    def create_plugin
      @filename = File.basename(name)
      @module_name = @filename.camelize
      @path = name
      template 'gemspec',         "#{@path}/#{@filename}.gemspec"
      template 'module.rb',       "#{@path}/lib/#{@filename}.rb"
      template 'railtie.rb',      "#{@path}/lib/#{@filename}/railtie.rb"
      template 'taglib.dryml',    "#{@path}/taglibs/#{@filename}.dryml"
      template 'javascript.js',   "#{@path}/vendor/assets/javascripts/#{@filename}.js"
      template 'stylesheet.css',  "#{@path}/vendor/assets/stylesheets/#{@filename}.css"
      template 'helper.rb',       "#{@path}/app/helpers/#{@filename}_helper.rb"
    end
  end
end

