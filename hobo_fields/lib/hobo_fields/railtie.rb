require 'hobo_fields'
require 'rails'

module HoboFields
  class Railtie < Rails::Railtie

    ActiveSupport.on_load(:active_record) do
      require 'hobo_fields/features/active_record/attribute_methods'
      require 'hobo_fields/features/active_record/fields_declaration'
    end

  end
end
