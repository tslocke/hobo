require 'bundler/cli'
module Hobo
  class InstallPluginGenerator < Rails::Generators::NamedBase

    include Generators::Hobo::Plugin

    desc """This generator installs a hobo plugin.

The first argument is the name of the plugin, and the second is where
to get it.  If the second argument is not supplied, it is installed
from rubygems.org or any other gem source listed in your Gemfile.  If
the second argument contains a colon (:), it is assumed to be a git
URL.  Otherwise it is considered to be a path.

If you are installing a Hobo theme, you probably want to use the options
`--subsite=front --css-top`.
"""

    argument :name, :desc => "the plugin name"
    argument :git_path, :required => false, :desc => "if supplied, is passed to the :git or :path option in the gemfile"
    class_option :skip_gem, :type => :boolean, :aliases => '-M', :desc => "don't add plugin to Gemfile"
    class_option :skip_js, :type => :boolean, :aliases => '-J', :desc => "don't add require to application.js"
    class_option :skip_css, :type => :boolean, :aliases => '-C', :desc => "doesn't add require to application.css"
    class_option :version, :type => :string, :aliases => '-v', :desc => "Gemspec version string"
    class_option :comments, :type => :string, :desc => "comments to add before require/include"
    class_option :subsite, :type => :string, :aliases => '-e', :default => "application", :desc => "Subsite name (without '_site') or 'all' or 'application'"
    class_option :css_top, :type => :boolean, :desc => "add the require statement to the top of the CSS file rather tahn the bottom."

    def install_plugin
      if install_plugin_helper(name, git_path, options)
        invoke(Bundler::CLI, :update, [], {})
      end
    end
  end
end

