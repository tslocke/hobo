require 'hobo'
require 'rails'

module Hobo
  class Engine < Rails::Engine

    ActiveSupport.on_load(:before_configuration) do
      h = config.hobo = ActiveSupport::OrderedOptions.new
      h.developer_features = Rails.env.in?(["development", "test"])

    end

    ActiveSupport.on_load(:action_controller) do
      include Hobo::ControllerMethods
    end

    initializer 'hobo.enable' do
      require 'hobo/extensions'
      # Modules that must *not* be auto-reloaded by activesupport
      # (explicitly requiring them means they're never unloaded)
      require 'hobo/model_router'
      require 'hobo/undefined'
      require 'hobo/user'
   #   require 'dryml'
   #   require 'dryml/template'
   #   require 'dryml/dryml_generator'

      Hobo::Model.enable
   #   Dryml.enable(["#{HOBO_ROOT}/rapid_generators"], "#{RAILS_ROOT}/app/views/taglibs/auto")
      Hobo::Permissions.enable
      Hobo::ViewHints.enable
    end

    initialize 'hobo.hobo_fields' do
      HoboFields.never_wrap(Hobo::Undefined) if defined? HoboFields
    end

  end
end
