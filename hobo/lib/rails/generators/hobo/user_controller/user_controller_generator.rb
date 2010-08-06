module Hobo
  class UserControllerGenerator < Rails::Generators::NamedBase
    source_root File.expand_path('../templates', __FILE__)
    include Hobo::Generators::ControllerModule
    include Hobo::Generators::InviteOnlyModule

    def self.banner
      "rails generate hobo:user_controller #{self.arguments.map(&:usage).join(' ')} [--invite-only]"
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
