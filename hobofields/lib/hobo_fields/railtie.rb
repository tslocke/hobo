require 'hobo_fields'
require 'rails'

module HoboFields
  class Railtie < Rails::Railtie

#    initializer :eager_load_rich_types, :after => :set_autoload_paths do |app|
#      app.config.eager_load_paths += %W( #{app.config.root}/app/rich_types )
#      Dir[app.config.root.join('app', 'rich_types', '*.rb')].each do |f|
#        # TODO: should we complain if field_types doesn't get a new value? Might be useful to warn people if they're missing a register_type
#        require_dependency f
#      end
#    end

  ActiveSupport.on_load(:active_record) do
    # Add the fields do declaration to ActiveRecord::Base
    include HoboFields::FieldsDeclaration
    # Override ActiveRecord's default methods so that the attribute read & write methods
    # automatically wrap richly-typed fields.
    include HoboFields::AttributeMethods
  end

  end
end
