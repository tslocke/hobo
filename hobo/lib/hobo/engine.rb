require 'hobo'
require 'rails'


module Hobo
  class Engine < Rails::Engine

    ActiveSupport.on_load(:before_configuration) do
      h = config.hobo = ActiveSupport::OrderedOptions.new
      h.developer_features = Rails.env.in?(["development", "test"])
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
      require 'hobo/model_router'
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


  end
end
