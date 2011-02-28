module Hobo
  class RapidGenerator < Rails::Generators::Base
    source_root File.expand_path('../templates', __FILE__)

    def self.banner
      "rails generate hobo:rapid"
    end

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
      directory "themes/clean-sidemenu/public","public/hobothemes/clean-sidemenu"
      directory "themes/clean-sidemenu/views", "app/views/taglibs/themes/clean-sidemenu"
    end

  end
end
