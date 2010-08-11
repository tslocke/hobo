require 'hobo'
require 'rails'
require 'rails/generators'


module Hobo
  class Engine < Rails::Engine

    config.to_prepare do
      # generators are used in other to_prepare blocks
      Rails::Generators.configure!
    end

    ActiveSupport.on_load(:before_configuration) do
      h = config.hobo = ActiveSupport::OrderedOptions.new
      h.developer_features = Rails.env.in?(["development", "test"])
      h.routes_path = Pathname.new File.expand_path('config/hobo_routes.rb', Rails.root)
    end

    ActiveSupport.on_load(:action_controller) do
      require 'hobo/features/action_controller/hobo_methods'
    end

    ActiveSupport.on_load(:active_record) do
      require 'hobo/features/active_record/association_collection'
      require 'hobo/features/active_record/association_proxy'
      require 'hobo/features/active_record/association_reflection'
      require 'hobo/features/active_record/hobo_methods'
      require 'hobo/features/active_record/i18n'
      require 'hobo/features/active_record/permissions'
    end

    ActiveSupport.on_load(:action_view) do
      require 'hobo/features/action_view/tag_helper'
    end

    ActiveSupport.on_load(:before_initialize) do
      # Modules that must *not* be auto-reloaded by activesupport
      # (explicitly requiring them means they're never unloaded)
      require 'hobo/routes'
      require 'hobo/undefined'
      require 'hobo/user'
   #   require 'dryml'
   #   require 'dryml/template'
   #   require 'dryml/dryml_generator'

   #   Dryml.enable(["#{HOBO_ROOT}/rapid_generators"], "#{RAILS_ROOT}/app/views/taglibs/auto")

      # should not be needed
      # ActiveSupport::Dependencies.load_paths |= ["#{RAILS_ROOT}/app/viewhints"]

      HoboFields.never_wrap(Hobo::Undefined)

    end

    initializer 'hobo.routes' do |app|
      h = app.config.hobo
      # generate at first boot, so no manual generation is required
      Rails::Generators.invoke('hobo:routes', %w[-f -q]) unless File.exists?(h.routes_path)
      app.routes_reloader.paths << h.routes_path
      app.config.to_prepare do
        # generate before each request in development
        Rails::Generators.invoke('hobo:routes', %w[-f -q])
      end
    end

  end
end
