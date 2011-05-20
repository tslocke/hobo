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

    def generate_admin_css
      template "admin.css", File.join("public/stylesheets/#{file_name}.css")
    end

    def generate_admin_user_controller
      invoke "hobo:controller", ["#{file_name}/#{options[:user_resource_name].pluralize.underscore}"], options
      template "users_index.dryml", "app/views/#{file_name}/#{options[:user_resource_name].pluralize.underscore}/index.dryml"
    end

    def generate_site_taglib
      invoke 'hobo:subsite_taglib', [name], options.merge(:admin => true)
    end

    def append_admin_tag_into_application_taglib
      destination = File.join(Rails.root, "app/views/taglibs/application.dryml")
      append_file(destination) { eval_template('admin_tag_injection.erb') }
    end

    include Generators::Hobo::Subsite

  end
end
