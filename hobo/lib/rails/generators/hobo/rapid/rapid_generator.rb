module Hobo
  class RapidGenerator < Rails::Generators::Base
    source_root File.expand_path('../templates', __FILE__)

    def self.banner
      "rails generate hobo:rapid [options]"
    end

    class_option :import_tags,
                 :type => :boolean,
                 :desc => "Modify taglibs/application.dryml to import hobo-rapid and theme tags"

    def copy_rapid_files
      copy_file "hobo-rapid.js",      "public/javascripts/hobo-rapid.js"
      copy_file "lowpro.js",          "public/javascripts/lowpro.js"
      copy_file "IE7.js",             "public/javascripts/IE7.js"
      copy_file "ie7-recalc.js",      "public/javascripts/ie7-recalc.js"
      copy_file "blank.gif",          "public/javascripts/blank.gif"
      copy_file "reset.css",          "public/stylesheets/reset.css"
      copy_file "hobo-rapid.css",     "public/stylesheets/hobo-rapid.css"
      directory "themes/clean/public","public/hobothemes/clean"
      directory "themes/clean/views", "app/views/taglibs/themes/clean"
    end

    def prepend_rapid_tags_into_application_taglib
      return unless options[:import_tags]
      source  = File.expand_path(find_in_source_paths('rapid_tags_injection.erb'))
      destination = File.join(Rails.root, "app/views/taglibs/application.dryml")
      context = instance_eval('binding')
      prepend_file destination do
        ERB.new(::File.binread(source), nil, '-').result(context)
      end
    end

  end
end
