# Generators

The following command in a hobo/rails dir shows all the generators available:

    $ hobo g --help

(or)

    $ rails g --help


Under the 'Hobo' group we find the hobo generators:

      hobo:admin_subsite
      hobo:assets
      hobo:controller
      hobo:front_controller
      hobo:i18n
      hobo:install_default_plugins
      hobo:install_plugin
      hobo:migration
      hobo:model
      hobo:resource
      hobo:routes
      hobo:setup_wizard
      hobo:subsite
      hobo:subsite_taglib
      hobo:test_framework
      hobo:user_controller
      hobo:user_mailer
      hobo:user_model
      hobo:user_resource

You can get more help about any generator (e.g. the 'hobo:resource' generator) by typing:

    $ hobo g resource --help

(which is the same as)

    $ rails g hobo:resource --help

Notice, if you use the hobo command you can omit the 'hobo:' namespace prepended to hobo generators.

The following options are common options for all the generators:

Runtime options:

    -q, [--quiet]    # Suppress status output
    -f, [--force]    # Overwrite files that already exist
    -s, [--skip]     # Skip files that already exist
    -p, [--pretend]  # Run but do not make any changes

SUGGESTION: the -p or --pretend option can be passed to all generators.
It will run the generator without actually producing any changes, so it is very useful
to see what a generator would do without making any changes to your app.

## hobo:setup_wizard generator

This is the generator that the hobo command invokes after creating the rails infrastructure by calling others generators in the background. In interactive mode (the default) it will ask you a few questions in order to customize the new application. It can also accept static options when you invoke it manually (when you choose the --skip-setup options of the hobo command).

Here are the static options as printed by the --help option:

        [--migration-migrate]                            # Generate migration and migrate
                                                         # Default: true
        [--fixture-replacement=FIXTURE_REPLACEMENT]      # Use a specific fixture replacement
        [--fixtures]                                     # Add the fixture option to the test framework
                                                         # Default: true
        [--wizard]                                       # Ask instead using options
                                                         # Default: true
        [--update]                                       # Run bundle update to install the missing gems
    -i, [--invite-only]                                  # Add features for an invite only website
        [--git-repo]                                     # Create the git repository with the initial commit
        [--front-controller-name=FRONT_CONTROLLER_NAME]  # Front Controller Name
                                                         # Default: front
        [--gitignore-auto-generated-files]               # Add the auto-generated files to .gitignore
                                                         # Default: true
        [--default-locale=DEFAULT_LOCALE]                # Sets the default locale
        [--admin-subsite-name=ADMIN_SUBSITE_NAME]        # Admin Subsite Name
                                                         # Default: admin
        [--dryml-only-templates]                         # The application uses only dryml templates
                                                         # Default: true
        [--user-resource-name=USER_RESOURCE_NAME]        # User Resource Name
                                                         # Default: user
    -t, [--test-framework=TEST_FRAMEWORK]                # Use a specific test framework
                                                         # Default: test_unit
        [--locales=one two three]                        # Choose the locales
                                                         # Default: en
        [--private-site]                                 # Make the site unaccessible to non-members
        [--activation-email]                             # Send an email to activate the account
        [--migration-generate]                           # Generate migration only
        [--main-title]                                   # Shows the main title
                                                         # Default: true

Here they are in the order they get used by the setup_wizard, which is
also the same order that the setup_wizard asks the questions.



### Hobo Setup Wizard

#### --main-title

Shows the main title (used internally just for aesthetic reasons)



### Startup

Invokes the hobo:assets generator.  It just copies a few files needed
by all Hobo applications.



### Test Framework

#### --test-framework=TEST_FRAMEWORK

Invokes the hobo:test_framework generator.

Interactively set by:`Do you want to customize the test_framework?`
and`Choose your preferred test framework: [<enter>=test_unit|rspec|shoulda|rspec_with_shoulda]`.

This gives you the opportunity to change the test framework.
Subsequent generators will use it for generating tests.   The default
choice is `test_unit` (Test::Unit)

#### --fixtures  
Interactively set by `Do you want the test framework to generate the fixtures?`.

If set, fixtures are generated.

#### --fixture-replacement=FIXTURE_REPLACEMENT 

Interactively set by: `Type your preferred fixture replacement or <enter> for no replacement:`.

This option is passed to the Rails3 generator.  If you do not have the
chosen fixture replacement installed bundler will attempt to install
it.  One list of available replacements is on
(ruby-toolbox.com)[http://ruby-toolbox.com/categories/testing_frameworks.html],
but there are probably others available.

### User Resource

#### --user-resource-name

Invokes the hobo:user_resource generator.

Interactively set by: `Choose a name for the user resource [<enter>=user|<custom_name>]:`.

You can choose a different name for the user model.

#### --activation-email

 Interactively set by: `Do you want to send an activation email to activate the user?`.

New users will receive an activation email containing an activation link if
this option is set.



### Invite Only Option

#### --invite-only | -i 
Interactively set by: `Do you want to add the features for an invite only website?`.

Subsequent generators will create an admin site and the resources used
to invite a new user if this option is chosen.

#### --private-site

Interactively set by: `Do you want to prevent all access to the site to non-members?   (Choose 'y' only if ALL your site will be private, choose 'n' if at least one controller will be public)` 

If you choose 'n', the wizard will print the instructions detailing
how to make a single controller private.



### Templates Option

#### --dryml-only-templates

Interactively set by: `Will your application use only hobo/dryml web page templates?  (Choose 'n' only if you also plan to use plain rails/erb web page templates) [y|n]`.

This will remove a few Rails files that are not needed by an
application that only uses Dryml templates.



### Hobo Rapid

Invokes the hobo:rapid generator which copies some files needed by the
Rapid tag library in Hobo.



### Front Controller

#### --front-controller-name

Invokes the hobo:front\_controller generator.

Internally set by: `Choose a name for the front controller [<enter>=front|<custom_name>]:`.



### Admin Subsite

#### --admin-subsite-name 

Invokes the hobo:admin_subsite generator.

Interactively set by: `Choose a name for the admin subsite [<enter>=admin|<custom_name>]:`.



### DB Migration

Invokes the hobo:migration generator.

The following options are interactively set by: `Initial Migration: [s]kip, [g]enerate migration file only, generate and [m]igrate [s|g|m]:`

#### --migration-migrate

Invoked if 'm' is chosen.   It  generates the migration and migrates the DB.

#### --migration-generate

Invoked if 'g' is chosen.  This option  only generates the migration.
Type `rake db:migrate` to perform the migration.



### I18n

Invokes the hobo:i18n generator.

#### --locales 
Interactively set by: `Type the locales (space separated) you want to add to your application or <enter> for 'en':`.

This copies the locale files for the supported locales

#### --default-locale
 Interactively set by: `Do you want to set a default locale? Type the locale or <enter> to skip:`.

This sets the config.i18n.default_locale in `config/application.rb`.



### Git Repository

#### --git-repo

 Interactively set by: `Do you want to initialize a git repository now?`.

This will initialize a git repository and commit the newly generated application.

#### --gitignore-auto-generated-files

 Interactively set by: 

    Do you want git to ignore the auto-generated files? 
    (Choose 'n' only if you are planning to deploy on a read-only File
    System like Heroku)

This will add the auto-generated files to .gitignore. In read-only
file systems like Heroku, this feature would be counter-productive, so
in that case is better also committing the auto generated files.

NOTE: You can later use most of the generators used by the
setup_wizard in order to override/restore any modified/generated file.
