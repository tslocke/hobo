require 'bundler/cli'
module Hobo
  class InstallPluginGenerator < Rails::Generators::NamedBase
    desc "This generator installs a hobo plugin"
    argument :name, :desc => "the plugin name"
    argument :git_path, :required => false, :desc => "if supplied, is passed to the :git option in the gemfile"
    class_option :skip_gem, :type => :boolean, :aliases => '-M', :desc => "don't add plugin to Gemfile"
    class_option :skip_js, :type => :boolean, :aliases => '-J', :desc => "don't add require to application.js"
    class_option :skip_css, :type => :boolean, :aliases => '-C', :desc => "doesn't add require to application.css"
    class_option :version, :type => :string, :aliases => '-v', :desc => "Gemspec version string"
    class_option :subsite, :type => :string, :aliases => '-e', :default => "application", :desc => "Subsite name (without '_site') or 'all' or 'application'"
    def install_plugin
      unless options[:skip_gem]
        gem_options = {}
        gem_options[:version] = options[:version] if options[:version]
        gem_options[:git] = git_path if git_path
        gem(name, gem_options)
      end

      if options[:subsite] == "all"
        if Hobo.subsites.blank?
          subsites = ['application']
        else
          subsites = ['front'] + Hobo.subsites
        end
      else
        subsites = [options[:subsite]]
      end

      subsites.each do |subsite|
        inject_js_require(name, subsite) unless options[:skip_js]
        inject_css_require(name, subsite) unless options[:skip_css]
        inject_dryml_include(name, subsite)
      end

      invoke Bundler::CLI, :update unless options[:skip_gem]
    end

  protected
    def inject_js_require(name, subsite)
      application_file = "app/assets/javascripts/#{subsite}.js"
      pattern          = /\/\/=(?!.*\/\/=).*?$/m

      unless exists?(application_file)
        application_file = "#{application_file}.coffee"
        pattern          = /#=(?!.*#=).*?$/m
      end

      raise Thor::Error, "Couldn't find either #{subsite}.js or #{subsite}.js.coffee files!" unless exists?(application_file)

      inject_into_file application_file, :before=>pattern do
        "//= require #{name}\n"
      end
    end

    def inject_css_require(name, subsite)
      application_file = "app/assets/stylesheets/#{subsite}.css"
      pattern          = /\*=(?!.*\*=).*?$/m

      raise Thor::Error, "Couldn't find #{subsite}.css!" unless exists?(application_file)

      inject_into_file application_file, :before=>pattern do
        "*= require #{name}\n "
      end
    end

    def inject_dryml_include(name, subsite)
      subsite = "#{subsite}_site" unless subsite=="application"
      application_file = "app/views/taglibs/#{subsite}.dryml"
      pattern          = /\<include.*?\>(?!.*\<include.*?\>).*?\n/m

      raise Thor::Error, "Couldn't find #{subsite}.dryml!" unless exists?(application_file)

      inject_into_file application_file, :after=>pattern do
        "<include gem='#{name}'/>\n"
      end
    end


    def exists?(file)
      File.exist?(File.join(destination_root, file))
    end
  end
end

