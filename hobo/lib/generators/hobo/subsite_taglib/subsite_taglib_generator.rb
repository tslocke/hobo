module Hobo
  class SubsiteTaglibGenerator < Rails::Generators::NamedBase
    source_root File.expand_path('../templates', __FILE__)
    include Generators::Hobo::InviteOnly
    include Generators::Hobo::Helper

    argument :user_resource_name, :type => :string, :default => 'user', :optional => true

    class_option :admin,
                 :type => :boolean,
                 :desc => "Includes the tags for the admin site"

    def self.banner
      "rails generate hobo:site_taglib NAME [USER_RESOURCE_NAME=user] [options]"
    end

    def generate_taglib
      template "taglib.dryml.erb", File.join('app/views/taglibs', "#{file_name}_site.dryml")
    end

  end
end
