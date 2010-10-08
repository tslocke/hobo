module Hobo
  class AdminSubsiteGenerator < Rails::Generators::NamedBase
    source_root File.expand_path('../templates', __FILE__)

    # overrides the default
    argument :name, :type => :string, :default => 'admin', :optional => true

    include Generators::Hobo::Subsite
    include Generators::Hobo::InviteOnly

    def self.banner
      "rails generate hobo:admin_subsite [NAME=admin] [options]"
    end

    def generate_admin_css
      template "admin.css", File.join("public/stylesheets/#{file_name}.css")
    end

    def generate_admin_user_controller
      invoke "hobo:controller", ["#{file_name}/#{options[:user_resource_name].pluralize.underscore}"]
      template "users_index.dryml", "app/views/#{file_name}/#{options[:user_resource_name].pluralize.underscore}/index.dryml"
    end

    def generate_site_taglib
      invoke 'hobo:subsite_taglib', [name],
                                    :user_resource_name => options[:user_resource_name],
                                    :admin => true,
                                    :invite_only => invite_only?
    end

    def append_admin_tag_into_application_taglib
      source  = File.expand_path(find_in_source_paths('admin_tag_injection.erb'))
      destination = File.join(Rails.root, "app/views/taglibs/application.dryml")
      context = instance_eval('binding')
      append_file destination do
        ERB.new(::File.binread(source), nil, '-').result(context)
      end
    end


  end
end
