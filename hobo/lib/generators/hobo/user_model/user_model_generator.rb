module Hobo
  class UserModelGenerator < Rails::Generators::NamedBase
    source_root File.expand_path('../templates', __FILE__)
    include Generators::Hobo::Model
    include Generators::Hobo::InviteOnly

    # overrides the default
    argument :name, :type => :string, :default => 'user', :optional => true

    def self.banner
      "rails generate hobo:user_model [NAME=user] [options]"
    end

    def generate_model
      template 'model.rb.erb', File.join('app/models', "#{file_path}.rb")
    end

    def generate_mailer
      invoke 'hobo:user_mailer', [name], :invite_only => options[:invite_only]
    end

    hook_for :test_framework, :as => :model

  end
end
