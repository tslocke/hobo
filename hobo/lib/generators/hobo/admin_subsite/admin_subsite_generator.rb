module Hobo
  class AdminSubsiteGenerator < Rails::Generators::NamedBase
    source_root File.expand_path('../templates', __FILE__)

    # overrides the default
    argument :name, :type => :string, :default => 'admin', :optional => true

    class_option :theme, :type => :string, :desc => "Theme", :default => 'clean_admin'
    class_option :ui_theme, :type => :string, :desc => "jQuery-UI Theme", :default => 'flick'

    include Generators::Hobo::InviteOnly
    include Generators::HoboSupport::EvalTemplate

    def self.banner
      "rails generate hobo:admin_subsite [NAME=admin] [options]"
    end

    def generate_admin_user_controller
      fixed_options = {:subsite_controller_is_being_created => 1}
      options.each{|k,v| fixed_options[k] = v}
      invoke "hobo:controller", ["#{file_name}/#{options[:user_resource_name].pluralize.underscore}"], fixed_options
      template "users_index.dryml", "app/views/#{file_name}/#{options[:user_resource_name].pluralize.underscore}/index.dryml" if invite_only?
    end

    include Generators::Hobo::Subsite

    def generate_site_taglib
      invoke 'hobo:subsite_taglib', [name], options.merge(:admin => true)
    end

  end
end
