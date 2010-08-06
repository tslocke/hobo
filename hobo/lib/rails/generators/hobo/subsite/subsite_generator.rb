module Hobo
  class SubsiteGenerator < Rails::Generators::NamedBase
    source_root File.expand_path('../templates', __FILE__)

    def self.banner
      "rails generate hobo:subsite #{self.arguments.map(&:usage).join(' ')} [options]"
    end

    include Hobo::Generators::SubsiteModule

  end
end
