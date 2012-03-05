module Hobo
  class AssetsGenerator < Rails::Generators::Base
    source_root File.expand_path('../templates', __FILE__)

    def self.banner
      "rails generate hobo:assets"
    end

    def copy_rapid_files
      template  'application.dryml.erb',        'app/views/taglibs/application.dryml'
      #copy_file 'dryml-support.js',             'public/javascripts/dryml-support.js'
      copy_file 'dryml_taglibs_initializer.rb', 'config/initializers/dryml_taglibs.rb'
      copy_file 'guest.rb',                     'app/models/guest.rb'

      FileUtils.mv 'app/assets/stylesheets/application.css', 'app/assets/stylesheets/application.css.orig'
      copy_file 'application.css',                        'app/assets/stylesheets/application.css'
      copy_file 'gitkeep',                                'app/assets/stylesheets/application/.gitkeep'
      copy_file 'front.css',                              'app/assets/stylesheets/front.css'
      copy_file 'gitkeep',                                'app/assets/stylesheets/front/.gitkeep'

      FileUtils.mv 'app/assets/javascripts/application.js', 'app/assets/javascripts/application.js.orig'
      copy_file 'application.js',                        'app/assets/javascripts/application.js'
      copy_file 'gitkeep',                               'app/assets/javascripts/application/.gitkeep'
      copy_file 'front.js',                              'app/assets/javascripts/front.js'
      copy_file 'gitkeep',                               'app/assets/javascripts/front/.gitkeep'
    end

  end
end
