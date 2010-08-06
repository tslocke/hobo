module Hobo
  class AdminSubsiteGenerator < Rails::Generators::NamedBase

    source_root File.expand_path('../templates', __FILE__)
    include Hobo::Generators::SubsiteModule
    include Hobo::Generators::InviteOnlyModule

    def self.banner
      "rails generate hobo:admin_subsite #{self.arguments.map(&:usage).join(' ')} [options]"
    end

    def generate_admin_css
      template "admin.css", File.join('public/stylesheets/admin.css')
    end

    def generate_for_invite_only
      return unless invite_only?
      invoke "hobo:controller", ["admin/user"]
      template "users_index.dryml", "app/views/admin/users/index.dryml"
    end

  end
end
