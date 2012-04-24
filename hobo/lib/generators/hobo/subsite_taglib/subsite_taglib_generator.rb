module Hobo
  class SubsiteTaglibGenerator < Rails::Generators::NamedBase
    source_root File.expand_path('../templates', __FILE__)
    include Generators::Hobo::InviteOnly
    include Generators::Hobo::Taglib

    def self.banner
      "rails generate hobo:subsite_taglib NAME [options]"
    end

    def generate_taglib
      template "taglib.dryml.erb", File.join('app/views/taglibs', "#{file_name}_site.dryml")
      Rails::Generators.invoke('hobo:install_default_plugins', ["--subsite=#{file_name}", "--theme=hobo_clean_admin", "--ui_theme=flick"])
    end

  end
end
