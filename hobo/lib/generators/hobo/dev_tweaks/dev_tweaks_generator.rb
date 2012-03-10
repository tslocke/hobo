require 'bundler/cli'
module Hobo
  class DevTweaksGenerator < Rails::Generators::Base

    include Generators::Hobo::Plugin

    desc "install the rails-dev-tweaks plugin & configure it"
    def add_dev_tweaks
      say "Adding rails-dev-tweaks gem"
      gem_with_comments('rails-dev-tweaks', :version => "~> 0.6.1", :comments => "\n# The asset pipeline in Rails is really slow in development mode.\n# Hobo has a lot of assets, so speed it up with rails-dev-tweaks", :group => ":development")
      Bundler.with_clean_env do
        run "bundle install"
      end

      # environment :env => :development action is broken
      inject_into_file "config/environments/development.rb", :before => /end(?!.*end)/m do
        """
  # By default, rails-dev-tweaks also applies to XHR, but that's not a great default for Hobo
  config.dev_tweaks.autoload_rules do
    keep :all

    skip '/favicon.ico'
    skip :assets
    keep :xhr
    keep :forced
  end
"""
      end
    end
  end
end
