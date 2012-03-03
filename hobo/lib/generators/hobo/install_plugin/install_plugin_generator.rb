require 'bundler/cli'
module Hobo
  class InstallPluginGenerator < Rails::Generators::NamedBase
    desc "This generator installs a hobo plugin"
    argument :name
    class_option :skip_gem, :type => :boolean, :aliases => '-M', :default => false, :desc => "don't add plugin to Gemfile"
    class_option :skip_js, :type => :boolean, :aliases => '-J', :default => false, :desc => "don't add require to application.js"
    class_option :skip_css, :type => :boolean, :aliases => '-C', :default => false, :desc => "doesn't add require to application.css"
    class_option :version, :type => :string, :aliases => '-v', :default => "", :desc => "Gemspec version string"
    def install_plugin
      unless options[:skip_gem]
        unless options[:version].blank?
          gem(name, options[:version])
        else
          gem(name)
        end
      end

      inject_js_require(name) unless options[:skip_js]
      inject_css_require(name) unless options[:skip_css]
    end

  protected
    def inject_js_require(name)
      application_file = "app/assets/javascripts/application.js"
      pattern          = /\/\/=(?!.*\/\/=).*?$/m

      unless exists?(application_file)
        application_file = "#{application_file}.coffee"
        pattern          = /#=(?!.*#=).*?$/m
      end

      raise Thor::Error, "Couldn't find either application.js or application.js.coffee files!" unless exists?(application_file)

      inject_into_file application_file, :before=>pattern do
        "//= require #{name}\n"
      end
    end

    def inject_css_require(name)
      application_file = "app/assets/stylesheets/application.css"
      pattern          = /\*=(?!.*\*=).*?$/m

      raise Thor::Error, "Couldn't find application.css!" unless exists?(application_file)

      inject_into_file application_file, :before=>pattern do
        "*= require #{name}\n "
      end
    end

    def exists?(file)
      File.exist?(File.join(destination_root, file))
    end
  end
end

