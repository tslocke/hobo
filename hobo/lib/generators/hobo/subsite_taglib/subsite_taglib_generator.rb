module Hobo
  class SubsiteTaglibGenerator < Rails::Generators::NamedBase
    source_root File.expand_path('../templates', __FILE__)
    include Generators::Hobo::InviteOnly
    include Generators::Hobo::Taglib

    class_option :theme, :type => :string, :desc => "Theme", :default => 'clean_admin'
    class_option :ui_theme, :type => :string, :desc => "jQuery-UI Theme", :default => 'flick'

    def self.banner
      "rails generate hobo:subsite_taglib NAME [options]"
    end

    def generate_taglib
      template "taglib.dryml.erb", File.join('app/views/taglibs', "#{file_name}_site.dryml")
      Rails::Generators.invoke('hobo:install_default_plugins', ["--subsite=#{file_name}", "--theme=hobo_#{options[:theme]}", "--ui_theme=#{options[:ui_theme]}"])
    end

  end
end
