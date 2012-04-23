require 'fileutils'
require 'thor/parser/option'

module Generators
  module Hobo
    Subsite = classy_module do

      include Generators::Hobo::InviteOnly
      include Generators::Hobo::Taglib

      # check_class_collision :suffix => 'SiteController'

      def move_and_generate_files
        if can_mv_application_to_front_site?
          say "Renaming app/views/taglibs/application.dryml to app/views/taglibs/front_site.dryml"  unless options[:quiet]
          unless options[:pretend]
            FileUtils.mv('app/views/taglibs/application.dryml', "app/views/taglibs/front_site.dryml")
            copy_file "application.dryml", 'app/views/taglibs/application.dryml'
          end
        end

        template "site.css.erb", File.join('app/assets/stylesheets', "#{file_name}.css")
        copy_file "gitkeep", "app/assets/stylesheets/#{file_name}/.gitkeep"
        template "site.js.erb", File.join('app/assets/javascripts', "#{file_name}.js")
        copy_file "gitkeep", "app/assets/javascripts/#{file_name}/.gitkeep"

        template "controller.rb.erb", File.join('app/controllers', file_name, "#{file_name}_site_controller.rb")

        application "config.assets.precompile += %w(#{file_name}.css #{file_name}.js)"
      end

      hook_for :test_framework, :as => :controller do | instance, controller_test |
        instance.invoke controller_test, ["#{instance.name}_site"]
      end

      private

      def subsite_name
        class_name
      end

      def can_mv_application_to_front_site?
        File.exist?('app/views/taglibs/application.dryml') && !File.exist?('app/views/taglibs/front_site.dryml')
      end

    end
  end
end
