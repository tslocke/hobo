module Hobo
  class UserModelGenerator < Rails::Generators::NamedBase
    source_root File.expand_path('../templates', __FILE__)

    # overrides the default
    argument :name, :type => :string, :default => 'user', :optional => true

    include Generators::Hobo::Model
    include Generators::Hobo::InviteOnly

    def self.banner
      "rails generate hobo:user_model [NAME=user] [options]"
    end

  end
end
