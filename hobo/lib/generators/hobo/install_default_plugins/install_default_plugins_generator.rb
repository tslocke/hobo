require 'bundler/cli'
module Hobo
  class InstallDefaultPluginsGenerator < Rails::Generators::Base

    include Generators::Hobo::Plugin

    class_option :subsite, :type => :string, :aliases => '-e', :required => true, :desc => "Subsite name (without '_site') or 'all'"
    class_option :theme, :type => :string, :default => "hobo_clean", :desc => "the theme to install"
    class_option :ui_theme, :type => :string, :default => "redmond", :desc => "the jquery-ui theme to require"
    class_option :skip_gem, :type => :boolean, :desc => "add to Gemfile"

    def install_default_plugins
      opts = options.dup
      opts[:version] = Hobo::VERSION
      say "Installing default plugins for #{opts[:subsite]}..."
      say "Installing hobo_rapid plugin..."
      install_plugin_helper('hobo_rapid', nil, opts.merge(:skip_dryml => true, :skip_gem => true))
      say "Installing hobo_jquery plugin..."
      install_plugin_helper('hobo_jquery', nil, opts.merge(:skip_gem => true))
      say "Installing #{opts[:theme]} theme..."
      install_plugin_helper(opts[:theme], nil, opts)
      say "Installing hobo_jquery_ui plugin..."
      install_plugin_helper('hobo_jquery_ui', nil, opts)
      if opts[:theme]=='hobo_bootstrap'
        say "Installing hobo_bootstrap_ui plugin..."
        install_plugin_helper('hobo_bootstrap_ui', nil, opts)
      end

      inject_css_require("jquery-ui/#{opts[:ui_theme]}", opts[:subsite], nil)

      unless opts[:skip_gem]
        gem_with_comments("jquery-ui-themes", "~> 0.0.4")
        Bundler.with_clean_env do
          run "bundle update"
        end
      end

    end
  end
end

