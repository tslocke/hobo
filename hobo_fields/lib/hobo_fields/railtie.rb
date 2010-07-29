require 'hobo_fields'
require 'rails'

module HoboFields
  class Railtie < Rails::Railtie

    ActiveSupport.on_load(:active_record) do
      # Add the fields declaration to ActiveRecord::Base
      include HoboFields::FieldsDeclaration
      # Override ActiveRecord's default methods so that the attribute read & write methods
      # automatically wrap richly-typed fields.
      include HoboFields::AttributeMethods
    end

    # switches off the default migration of ActiveRecord model generator
    config.generators.orm :active_record, :migration => false

  end
end
