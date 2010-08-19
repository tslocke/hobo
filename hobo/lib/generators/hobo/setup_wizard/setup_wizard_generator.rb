require 'generators/hobo_support/thor_shell'
module Hobo
  class SetupWizardGenerator < Rails::Generators::Base

    source_root File.expand_path('../templates', __FILE__)

    include Generators::Hobo::Helper
    include Generators::HoboSupport::ThorShell


    def startup
      say_title 'Startup'
      say 'Initializing Hobo...'
      template  'application.dryml.erb',  'app/views/taglibs/application.dryml'
      copy_file 'application.css',    'public/stylesheets/application.css'
      copy_file 'dryml-support.js',   'public/javascripts/dryml-support.js'
      copy_file 'guest.rb',           'app/model/guest.rb'
    end

    def choose_test_framework
      say_title 'Test Framework'
      return unless yes_no? "Do you want to customize the test_framework?"
      require 'generators/hobo/test_framework/test_framework_generator'
      f = Hobo::TestFrameworkGenerator::FRAMEWORKS * '|'
      test_framework = choose("Choose your preferred test framework: [<enter>=#{f}]:", /^(#{f})$/, 'test_unit')
      fixtures = yes_no?("Do you want the test framework to generate the fixtures?")
      fixture_replacement = ask("Type your preferred fixture replacement or <enter> for no replacement:")
      invoke 'hobo:test_framework', [test_framework, fixture_replacement], :fixtures => fixtures
    end

    def invite_only_option
      say_title 'Invite Only Option'
      return unless (@invite_only = yes_no?("Do you want to add the features for an invite only website?"))
      say %(
Invite-only website
  If you wish to prevent all access to the site to non-members, add 'before_filter :login_required'
  to the relevant controllers, e.g. to prevent all access to the site, add

    include Hobo::AuthenticationSupport
    before_filter :login_required

  to application_controller.rb (note that the include statement is not required for hobo_controllers)

  NOTE: You might want to sign up as the administrator before adding this!
), Color::Yellow
    end

    def rapid
      say_title 'Hobo Rapid'
      say 'Installing Hobo Rapid and default theme...'
      invoke 'hobo:rapid', [], :invite_only => @invite_only
    end

    def user_resource
      say_title 'User Resource'
      @user_resource_name = ask("Choose a name for the user resource [<enter>=user|<custom_name>]:", 'user')
      say "Installing '#{@user_resource_name}' resources..."
      invoke 'hobo:user_resource', [@user_resource_name], :invite_only => @invite_only
    end

    def front_controller
      say_title 'Front Controller'
      front_controller_name = ask("Choose a name for the front controller [<enter>=front|<custom_name>]:", 'front')
      say "Installing #{front_controller_name} controller..."
      invoke 'hobo:front_controller', [front_controller_name], :invite_only => @invite_only
    end

    def admin_subsite
      say_title 'Admin Subsite'
      admin = @invite_only ? true : yes_no?("Do you want to add an admin subsite?")
      return unless admin
      admin_subsite_name = ask("Choose a name for the admin subsite [<enter>=admin|<custom_name>]:", 'admin')
      say "Installing admin subsite..."
      invoke 'hobo:admin_subsite', [admin_subsite_name, @user_resource_name], :invite_only => @invite_only
    end

    def migration
      say_title 'DB Migration'
      action = choose('Initial Migration: [s]kip, [g]enerate migration file only, generate and [m]igrate [s|g|m]:', /^(s|g|m)$/)
      opt = case action
            when 's'
              return say('Migration skipped!')
            when 'g'
              {:generate => true}
            when 'm'
              {:migrate => true}
            end
      say action == 'g' ? 'Generating Migration...' : 'Migrating...'
      invoke 'hobo:migration', ['initial_migration'], opt
    end

    def i18n
      say_title 'I18n'
      locales = Hobo::Engine.paths.config.locales.paths.map do |l|
        l =~ /hobo\.([^\/]+)\.yml$/
        $1.to_sym.inspect
      end
      say "The available Hobo internal locales are #{locales * ', '} (please, contribute to more translations)"
      default_locale = ask "Do you want to set a default locale? Type the locale or <enter> to skip:"
      return if default_locale.blank?
      default_locale.gsub!(/\:/, '')
      environment "config.i18n.default_locale = #{default_locale.to_sym.inspect}"
      say "NOTICE: You should manually install in 'config/locales' the Rails locale file(s) that your application will use.", Color::YELLOW
    end

    def git_repo
      say_title 'Git Repository'
      return unless yes_no?("Do you want to initialize a git repository now?")
      say 'Initializing git repository...'
      hobo_routes_rel_path = Hobo::Engine.config.hobo.routes_path.relative_path_from Rails.root
      append_file '.gitignore', "app/views/taglibs/auto/**/*\n#{hobo_routes_rel_path}\n"
      git :init
      git :add => '.'
      git :commit => '-m "initial commit"'
      say "NOTICE: If you change the config.hobo.routes_path, you should update the .gitignore file accordingly.", Color::YELLOW
    end

    def cleanup_app_template
      say_title 'Cleanup'
      # remove the template if one
      remove_file File.join(File.dirname(Rails.root), ".hobo_app_template")
    end

    def finalize
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

  end
end
