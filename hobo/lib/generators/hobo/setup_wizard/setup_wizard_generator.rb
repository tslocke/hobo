require 'generators/hobo_support/thor_shell'
require 'bundler/cli'
module Hobo
  class SetupWizardGenerator < Rails::Generators::Base

    source_root File.expand_path('../templates', __FILE__)

    include Generators::HoboSupport::ThorShell
    include Generators::Hobo::InviteOnly
    include Generators::Hobo::ActivationEmail
    include Generators::Hobo::TestOptions
    include Generators::Hobo::Taglib
    include Generators::Hobo::Plugin

    def self.banner
      "rails generate hobo:setup_wizard [options]"
    end

    class_option :main_title, :type => :boolean,
    :desc => "Shows the main title", :default => true

    class_option :wizard, :type => :boolean,
    :desc => "Ask instead using options", :default => true

    class_option :front_controller_name, :type => :string,
    :desc => "Front Controller Name", :default => 'front'

    class_option :front_theme, :type => :string,
    :desc => "Front Theme", :default => 'clean'

    class_option :front_ui_theme, :type => :string,
    :desc => "Front jQuery-UI Theme", :default => 'redmond'

    class_option :add_admin_subsite, :type => :boolean,
                 :desc => "Add an Admin Subsite"

    class_option :admin_subsite_name, :type => :string,
                 :desc => "Admin Subsite Name", :default => 'admin'

    class_option :admin_theme, :type => :string,
                 :desc => "Admin Theme", :default => 'clean'

    class_option :admin_ui_theme, :type => :string,
                 :desc => "Admin jQuery-UI Theme", :default => 'redmond'

    class_option :invite_only, :type => :boolean,
                 :desc => "Require invitation to join site"

    class_option :private_site, :type => :boolean,
                 :desc => "Make the site unaccessible to non-members"

    class_option :migration_generate, :type => :boolean,
    :desc => "Generate migration only"

    class_option :migration_migrate, :type => :boolean,
    :desc => "Generate migration and migrate", :default => true

    class_option :default_locale, :type => :string,
    :desc => "Sets the default locale"

    class_option :locales, :type => :array,
    :desc => "Choose the locales", :default => %w[en]

    class_option :git_repo, :type => :boolean,
    :desc => "Create the git repository with the initial commit"

    class_option :gitignore_auto_generated_files, :type => :boolean,
    :desc => "Add the auto-generated files to .gitignore", :default => true

    class_option :dryml_only_templates, :type => :boolean,
    :desc => "The application uses only dryml templates",
    :default => Rails.application.config.hobo.dryml_only_templates

    def startup
      if wizard?
        say_title options[:main_title] ? 'Hobo Setup Wizard' : 'Startup'
        say 'Installing Hobo assets...'
      end
      invoke 'hobo:assets'
    end

    def choose_test_framework
      if wizard?
        say_title 'Test Framework'
        return unless yes_no? "Do you want to customize the test_framework?"
        require 'generators/hobo/test_framework/test_framework_generator'
        f = Hobo::TestFrameworkGenerator::FRAMEWORKS * '|'
        test_framework = choose("Choose your preferred test framework: [<enter>=#{f}]:", /^(#{f})$/, 'test_unit')
        fixtures = yes_no?("Do you want the test framework to generate the fixtures?")
        fixture_replacement = ask("Type your preferred fixture replacement or <enter> for no replacement:")
      else
        # return if it is all default so no invoke is needed
        return if (options[:test_framework].to_s == 'test_unit' && options[:fixtures] && options[:fixture_replacement].blank?)
        test_framework = options[:test_framework]
        fixtures = options[:fixtures]
        fixture_replacement = options[:fixture_replacement]
      end
      invoke 'hobo:test_framework', [test_framework],
                                    :fixture_replacement => fixture_replacement,
                                    :fixtures => fixtures,
                                    :update => true
    end

    def user_options
      if wizard?
        say_title 'User Resource'
        @user_resource_name = ask("Choose a name for the user resource: [<enter>=user|<custom_name>]", 'user')
        @activation_email = @invite_only ? false : yes_no?("Do you want to send an activation email to activate the user?")
      else
        @user_resource_name = options[:user_resource_name]
        @activation_email = options[:activation_email]
      end
    end

    def site_options
      if wizard?
        say_title 'Invite Only Option'
        return unless (@invite_only = yes_no?("Do you want to add the features for an invite only website?"))
        private_site = yes_no?("Do you want to prevent all access to the site to non-members?\n(Choose 'y' only if ALL your site will be private, choose 'n' if at least one controller will be public)")
        say( %( If you wish to prevent all access to some controller to non-members, add 'before_filter :login_required'
to the relevant controllers:

    include Hobo::Controller::AuthenticationSupport
    before_filter :login_required

(note that the include statement is not required for hobo_controllers)

NOTE: You might want to sign up as the administrator before adding this!
), Color::YELLOW) unless private_site
      else
        @invite_only = invite_only?
        private_site = options[:private_site]
      end
      inject_into_file 'app/controllers/application_controller.rb', <<EOI, :after => "protect_from_forgery\n" if private_site
  include Hobo::Controller::AuthenticationSupport
  before_filter :except => [:login, :forgot_password, :accept_invitation, :do_accept_invitation, :reset_password,
:do_reset_password] do
     login_required unless #{@user_resource_name.camelize}.count == 0
  end
EOI
    end

    def dryml_only_templates_option
      if wizard?
        say_title 'Templates Option'
        dryml_only_templates = yes_no?("Will your application use only hobo/dryml web page templates?\n(Choose 'n' only if you also plan to use plain rails/erb web page templates)")
      else
        dryml_only_templates = options[:dryml_only_templates]
      end
      if dryml_only_templates
        remove_file 'app/views/layouts/application.html.erb'
        remove_file 'app/helpers/application_helper.rb'
        environment "#"
        environment "config.hobo.dryml_only_templates = true"
        environment "# Hobo: remove support for ERB templates"
      end
    end

    def dont_emit_deprecated_routes
      environment "#"
      environment "config.hobo.dont_emit_deprecated_routes = true"
      environment "# Hobo: Named routes have changed in Hobo 2.0.   Set to false to emit both the 2.0 and 1.3 names."
    end

    def quiet_assets
      say "Adding quiet_assets gem"
      gem_with_comments('quiet_assets', :group => :development, :comments => "\n# Hobo has a lot of assets.   Stop cluttering the log in development mode.")
    end

    def will_paginate
      say "Adding will_paginate gem"
      gem_with_comments('will_paginate', :git => "git://github.com/Hobo/will_paginate.git", :comments => "\n# Hobo's version of will_paginate is required.")
    end

    def front_controller
      if wizard?
        say_title 'Front Controller'
        front_controller_name = ask("Choose a name for the front controller: [<enter>=front|<custom_name>]", 'front')
        say "Installing #{front_controller_name} controller..."
      else
        front_controller_name = options[:front_controller_name]
      end
      invoke 'hobo:front_controller', [front_controller_name], :user_resource_name => @user_resource_name, :invite_only => @invite_only
    end

    def install_default_plugins
      if wizard?
        say_title 'Front Theme'
        say "The currently available themes are clean, clean_admin, clean_sidemenu and bootstrap."
        @front_theme = ask("Choose a theme for the front site: [<enter>=clean|<custom_name>]", 'clean')

        say_title 'Front jQuery-UI Theme'
        say "The currently available jQuery-UI themes are listed here: https://github.com/fatdude/jquery-ui-themes-rails/blob/master/README.markdown"
        @front_ui_theme = ask("Choose a jQuery-UI theme for the front site: [<enter>=redmond|<custom_name>]", 'redmond')
      else
        @front_theme = options[:front_theme]
        @front_ui_theme = options[:front_ui_theme]
      end
      invoke 'hobo:install_default_plugins', [], {:subsite => 'front', :theme => "hobo_#{@front_theme}", :ui_theme => @front_ui_theme, :skip_gem => false}
    end

    def admin_subsite
      if wizard?
        say_title 'Admin Subsite'
        if @invite_only || (@add_admin_subsite = yes_no?("Do you want an admin subsite?"))
          @admin_subsite_name = ask("Choose a name for the admin subsite: [<enter>=admin|<custom_name>]", 'admin')

          say "The currently available themes are clean, clean_admin, clean_sidemenu and bootstrap."
          @admin_theme = ask("Choose a theme for the #{@admin_subsite_name} site: [<enter>=clean_admin|<custom_name>]", 'clean_admin')

          say "The currently available jQuery-UI themes are listed here: https://github.com/fatdude/jquery-ui-themes-rails/blob/master/README.markdown"
          @admin_ui_theme = ask("Choose a jQuery-UI theme for the admin site: [<enter>=flick|<custom_name>]", 'flick')
        end
      else
        if @invite_only || (@add_admin_subsite = options[:add_admin_subsite])
          @admin_subsite_name = options[:admin_subsite_name]
          @admin_theme = options[:front_theme]
          @admin_ui_theme = options[:front_ui_theme]
        end
      end
    end

    def invoking_user_and_admin
      say "Installing '#{@user_resource_name}' resources..."
      invoke 'hobo:user_resource', [@user_resource_name],
                                   :invite_only => @invite_only,
                                   :activation_email => @activation_email,
                                   :admin_subsite_name => @admin_subsite_name
      if @invite_only || @add_admin_subsite
        say "Installing admin subsite..."
        invoke 'hobo:admin_subsite', [@admin_subsite_name],
                                     :user_resource_name => @user_resource_name,
                                     :invite_only => @invite_only,
                                     :theme => @admin_theme,
                                     :ui_theme => @admin_ui_theme
      end
    end

    def active_reload_dryml
      environment "#", :env => :development
      environment "config.watchable_dirs[File.join(config.root, 'app/views')] = ['dryml']", :env => :development
      environment "# Hobo: tell ActiveReload about dryml", :env => :development
    end

    def generate_migration
      if wizard?
        say_title 'DB Migration'
        action = choose("Initial Migration: [s]kip, [g]enerate migration file only, generate and [m]igrate: [s|g|m]", /^(s|g|m)$/)
        opt = case action
              when 's'
                return say('Migration skipped!')
              when 'g'
                {:generate => true}
              when 'm'
                {:migrate => true}
              end
        say action == 'g' ? 'Generating Migration...' : 'Migrating...'
      else
        return if !options[:migration_generate] && !options[:migration_migrate]
        opt = options[:migration_migrate] ? {:migrate => true} : {:generate => true}
      end
      rake 'db:setup'
      invoke 'hobo:migration', ['initial_migration'], opt
    end

    def i18n
      if wizard?
        say_title 'I18n'
        i18n_templates = File.expand_path('../../i18n/templates', __FILE__)
        supported_locales = Dir.glob("#{i18n_templates}/hobo.*.yml").map do |l|
          l =~ /([^\/.]+)\.yml$/
          $1
        end
        say "The Hobo supported locales are #{supported_locales * ' '} (please, contribute to more translations)"
        locales = ask("Type the locales (space separated) you want to add to your application or <enter> for 'en':", 'en').split(/\s/)
        unless locales.size == 1 && locales.first == 'en'
          default_locale = ask "Do you want to set a default locale? Type the locale or <enter> to skip:"
        end
      else
        default_locale = options[:default_locale]
        locales = options[:locales]
      end
      unless default_locale.blank?
        default_locale.gsub!(/\:/, '')
        environment "#"
        environment "config.i18n.default_locale = #{default_locale.to_sym.inspect}"
        environment "#"
      end
      ls = (locales - %w[en]).map {|l| ":#{l}" }
      lstr = ls.to_sentence
      invoke 'hobo:i18n', locales
      say(<<STR , Color::YELLOW) unless ls.empty?
NOTICE: You should manually install in 'config/locales' also the official Rails locale #{ls.size==1 ? 'file' : 'files'} for #{lstr} that your application will use.
Official rails I18n URLs:
  - Readme:     https://github.com/svenfuchs/rails-i18n/blob/master/README.md
  - locale dir: https://github.com/svenfuchs/rails-i18n/tree/master/rails/locale/
STR
    end

    def git_repo
      if wizard?
        say_title 'Git Repository'
        return unless yes_no?("Do you want to initialize a git repository now?")
        gitignore_auto_generated = yes_no? "Do you want git to ignore the auto-generated files?\n(Choose 'n' only if you are planning to deploy on a read-only File System like Heroku)"
        say 'Initializing git repository...'
      else
        return unless options[:git_repo]
        gitignore_auto_generated = options[:gitignore_auto_generated_files]
      end
      if gitignore_auto_generated
        hobo_routes_rel_path = Hobo::Engine.config.hobo.routes_path.relative_path_from Rails.root
        append_file '.gitignore', "app/views/taglibs/auto/**/*\n#{hobo_routes_rel_path}\n"
      end
      git :init
      git :add => '.'
      git :commit => '-m "initial commit"'
      say("NOTICE: If you change the config.hobo.routes_path, you should update the .gitignore file accordingly.", Color::YELLOW) if gitignore_auto_generated
    end

    def finalize
      return unless wizard?
      say_title 'Process completed!'
      say %(You can start your application with `rails server`
(run with --help for options). Then point your browser to
http://localhost:3000/

Follow the guidelines to start developing your application.
You can find the following resources handy:

* The Getting Started Guide: http://guides.rubyonrails.org/getting_started.html
* Ruby on Rails Tutorial Book: http://www.railstutorial.org/
)
end

private

  def wizard?
    options[:wizard]
  end

  end
end
