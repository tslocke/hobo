module Hobo
  class UserModelGenerator < Rails::Generators::NamedBase
    source_root File.expand_path('../templates', __FILE__)

    # overrides the default
    argument :name, :type => :string, :default => 'user', :optional => true

    include Generators::Hobo::Model
    include Generators::Hobo::InviteOnly
    include Generators::Hobo::ActivationEmail

    def self.banner
      "rails generate hobo:user_model [NAME=user] [options]"
    end

    class_option :admin_subsite_name,
                 :type => :string,
                 :desc => "Admin Subsite Name",
                 :default => 'admin'

  end
end
