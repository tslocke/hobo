module Hobo
  class UserControllerGenerator < Rails::Generators::NamedBase
    source_root File.expand_path('../templates', __FILE__)

    # overrides the default
    argument :name, :type => :string, :default => 'users', :optional => true

    include Generators::Hobo::Controller
    include Generators::Hobo::InviteOnly

    def self.banner
      "rails generate hobo:user_controller [NAME=users] [options]"
    end

    def generate_controller
      template 'controller.rb.erb', File.join('app/controllers',"#{file_path}_controller.rb")
    end

    def generate_accept_invitation
      return unless invite_only?
      template "accept_invitation.dryml", File.join('app/views', file_path, "accept_invitation.dryml")
    end

  end
end
