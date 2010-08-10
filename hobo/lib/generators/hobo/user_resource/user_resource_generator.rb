module Hobo
  class UserResourceGenerator < Rails::Generators::NamedBase

    # overrides the default
    argument :name, :type => :string, :default => 'user', :optional => true

    def self.banner
      "rails generate hobo:user_resource [NAME=user] [options]"
    end

    def generate_hobo_model
      invoke 'hobo:user_model', [name.singularize], options
    end

    def generate_hobo_user_controller
      invoke 'hobo:user_controller', [name.pluralize], options
    end

  end
end
