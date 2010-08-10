require 'generators/hobo_support/thor_shell'
module Hobo
  class SetupWizardGenerator < Rails::Generators::Base
    source_root File.expand_path('../templates', __FILE__)

    include Generators::HoboSupport::ThorShell

    def ask_site_wide_questions
      say 'Please, answer to these questions in order to customize your Hobo Application:'
      @invite_only   = yes_no?("Do you want to add the features for an invite only website?")
      @admin_subsite = @invite_only ? true : yes_no?("Do you want to add an admin subsite?")
    end

    def startup
      say 'Initializing Hobo...'
      invoke 'hobo:startup'
    end

    def rapid
      say 'Installing Hobo Rapid and default theme...'
      invoke 'hobo:rapid', :invite_only => @invite_only
    end

    def user_resource
      @user_resource_name = ask("Choose a name for the user resource (leave it blank for 'user') [user|<custom_name>]:", 'user')
      say "Installing #{@user_resource_name} resources..."
      invoke 'hobo:user_resource', [@user_resource_name], :invite_only => @invite_only
    end

    def front_controller
      front_controller_name = ask("Choose a name for the front controller (leave it blank for 'front') [front|<custom_name>]:", 'front')
      say "Installing #{front_controller_name} controller..."
      invoke 'hobo:front_controller', [front_controller_name], :invite_only => @invite_only
    end

    def admin_subsite
      return unless @amin_subsite
      admin_subsite_name = ask("Choose a name for the admin subsite (leave it blank for 'admin') [admin|<custom_name>]:", 'user')
      say "Installing admin subsite..."
      invoke 'hobo:admin_subsite', [admin_subsite_name, @user_resource_name], :invite_only => @invite_only
    end

    def gems
      say "Optional Gems..."
      gem 'will_paginate' if yes_no?("Do you want to use the 'will_paginate' gem in your application (recommended)?")
      gem 'meta_where' if yes_no?("Do you want to use the 'meta_where' gem in your application?")
      say "If you want to use other gems, please add them to the Gemfile"
    end

    def bundle_install
      return unless yes_no?("Do you want to run 'bundle install' now? (recommended)")
      puts run('bundle install')
    end

    def migration
      action = choose('Initial Migration: [s]kip, [g]enerate migration file only, generate and [m]igrate [s|g|m]:', /^(s|g|m)$/)
      opt = case action
            when 's'
              return say('Migration skipped!')
            when 'g'
              {:generate => true}
            when 'm'
              {:migrate => true}
            end
      invoke 'hobo:migration', ['initial_migration'], opt
    end

    def i18n
      # search for hobo available locales
      # choose default_locale
    end

    def git_repo
      return unless yes_no?("Do you want to initialize a git repository now?")
      copy_file 'gitignore', '.gitignore'
      git :init
      git :add => '.'
      git :commit => '-m "initial commit"'
    end

    def finalize
      say 'Process completed!'
      say <<EOF, Color::WHITE

You can start your application with `rails server`
(run with --help for options). Then point your browser to
http://localhost:3000/

Follow the guidelines to start developing your application.
You can find the following resources handy:

* The Getting Started Guide: http://guides.rubyonrails.org/getting_started.html
* Ruby on Rails Tutorial Book: http://www.railstutorial.org/
EOF
    end

  end
end
