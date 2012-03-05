module Hobo
  class AdminSubsiteGenerator < Rails::Generators::NamedBase
    source_root File.expand_path('../templates', __FILE__)

    # overrides the default
    argument :name, :type => :string, :default => 'admin', :optional => true

    include Generators::Hobo::InviteOnly
    include Generators::HoboSupport::EvalTemplate

    def self.banner
      "rails generate hobo:admin_subsite [NAME=admin] [options]"
    end

    def generate_admin_user_controller
      invoke "hobo:controller", ["#{file_name}/#{options[:user_resource_name].pluralize.underscore}"], options
      template "users_index.dryml", "app/views/#{file_name}/#{options[:user_resource_name].pluralize.underscore}/index.dryml"
    end

    def generate_site_taglib
      invoke 'hobo:subsite_taglib', [name], options.merge(:admin => true)
    end

    include Generators::Hobo::Subsite

  end
end
