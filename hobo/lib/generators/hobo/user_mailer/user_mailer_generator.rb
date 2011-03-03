module Hobo
  class UserMailerGenerator < Rails::Generators::NamedBase
    source_root File.expand_path('../templates', __FILE__)

    # overrides the default
    argument :name, :type => :string, :default => 'user', :optional => true

    include Generators::Hobo::InviteOnly
    include Generators::Hobo::ActivationEmail

    def self.banner
      "rails generate hobo:user_mailer [NAME=user] [options]"
    end

    # check_class_collision :suffix => 'Mailer'

    def generate_mailer
      template 'mailer.rb.erb', File.join('app/mailers', "#{file_path}_mailer.rb")
    end

    def generate_mails
      mailer_dir = File.join("app/views", class_path[0..-2], "#{file_name.singularize}_mailer")
      template 'forgot_password.erb', File.join(mailer_dir, "forgot_password.erb")
      template( 'invite.erb', File.join(mailer_dir, "invite.erb")) if invite_only?
      template( 'activation.erb', File.join(mailer_dir, "activation.erb")) if options[:activation_email]
    end

    hook_for :test_framework, :as => :mailer do | instance, mailer |
      instance.invoke mailer, ["#{instance.name}_mailer"]
    end

  end
end
