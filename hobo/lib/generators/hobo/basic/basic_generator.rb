module Hobo
  class BasicGenerator < Rails::Generators::Base
    source_root File.expand_path('../templates', __FILE__)

    def self.banner
      "rails generate hobo:basic"
    end

    def copy_rapid_files
      template  'application.dryml.erb', 'app/views/taglibs/application.dryml'
      copy_file 'application.css',       'public/stylesheets/application.css'
      copy_file 'dryml-support.js',      'public/javascripts/dryml-support.js'
      copy_file 'guest.rb',              'app/models/guest.rb'
    end

  end
end
