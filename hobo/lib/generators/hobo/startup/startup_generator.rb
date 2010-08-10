module Hobo
  class StartupGenerator < Rails::Generators::Base
    source_root File.expand_path('../templates', __FILE__)

    include Generators::Hobo::Helper

    def add_basic_resources
      gem 'hobo', Hobo::VERSION
      template  'application.dryml.erb',  'app/views/taglibs/application.dryml'
      copy_file 'application.css',    'public/stylesheets/application.css'
      copy_file 'dryml-support.js',   'public/javascripts/dryml-support.js'
      copy_file 'guest.rb',           'app/model/guest.rb'
    end

  end
end
