module Hobo
  class SubsiteGenerator < Rails::Generators::NamedBase
    source_root File.expand_path('../templates', __FILE__)

    def self.banner
      "rails generate hobo:subsite NAME [options]"
    end

    include Generators::Hobo::Subsite

    def generate_site_taglib
      invoke 'hobo:subsite_taglib', [name], options
    end

  end
end
