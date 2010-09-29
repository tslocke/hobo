require 'hobo'
require 'rails'
require 'rails/generators'


module Hobo
  class Engine < Rails::Engine

    ActiveSupport.on_load(:before_configuration) do
      h = config.hobo = ActiveSupport::OrderedOptions.new
      h.app_name = self.class.name.split('::').first.underscore.titleize
      h.developer_features = Rails.env.in?(["development", "test"])
      h.routes_path = Pathname.new File.expand_path('config/hobo_routes.rb', Rails.root)
      h.rapid_generators_path = Pathname.new File.expand_path('lib/hobo/rapid/generators', Hobo.root)
      h.auto_taglibs_path = Pathname.new File.expand_path('app/views/taglibs/auto', Rails.root)
    end

    ActiveSupport.on_load(:action_controller) do
      require 'hobo/features/action_controller/hobo_methods'
      require 'hobo/features/action_mailer/helper'
    end

    ActiveSupport.on_load(:active_record) do
      require 'hobo/features/active_record/association_collection'
      require 'hobo/features/active_record/association_proxy'
      require 'hobo/features/active_record/association_reflection'
      require 'hobo/features/active_record/hobo_methods'
      require 'hobo/features/active_record/permissions'
      require 'hobo/features/active_record/scopes'
      require 'hobo/features/active_model/name'
      require 'hobo/features/active_model/translation'
    end

    ActiveSupport.on_load(:action_view) do
      require 'hobo/features/action_view/tag_helper'
    end

    ActiveSupport.on_load(:before_initialize) do
      # Modules that must *not* be auto-reloaded by activesupport
      # (explicitly requiring them means they're never unloaded)
      require 'generators/hobo/routes/router'
      require 'hobo/routes'
      require 'hobo/undefined'

      h = config.hobo
      Dryml::DrymlGenerator.enable([h.rapid_generators_path], h.auto_taglibs_path)

      # should not be needed
      # ActiveSupport::Dependencies.autoload_paths |= ["#{Rails.root}/app/viewhints"]

      HoboFields.never_wrap(Hobo::Undefined)
    end

    initializer 'hobo.routes' do |app|
      h = app.config.hobo
      # generate at first boot, so no manual generation is required
      Rails::Generators.invoke('hobo:routes', %w[-f -q]) unless File.exists?(h.routes_path)
      app.routes_reloader.paths << h.routes_path
      app.config.to_prepare do
        Rails::Generators.configure!
        # generate before each request in development
        Rails::Generators.invoke('hobo:routes', %w[-f -q])
      end
    end

    initializer 'hobo.dryml' do |app|
      # avoids to fail the initial migration from the setup_wizard generator
      unless $0 =~ /rake$/
        app.config.to_prepare do
          Dryml::DrymlGenerator.run
        end
      end
    end

  end
end
