module Hobo
  class SubsiteGenerator < Rails::Generators::NamedBase
    source_root File.expand_path('../templates', __FILE__)

    class_option :theme, :type => :string, :desc => "Theme", :default => 'clean_admin'
    class_option :ui_theme, :type => :string, :desc => "jQuery-UI Theme", :default => 'flick'

    def self.banner
      "rails generate hobo:subsite NAME [options]"
    end

    include Generators::Hobo::Subsite

    def generate_site_taglib
      invoke 'hobo:subsite_taglib', [name], options
    end

  end
end
