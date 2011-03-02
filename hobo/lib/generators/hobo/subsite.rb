require 'fileutils'
module Generators
  module Hobo
    Subsite = classy_module do

      include Generators::Hobo::InviteOnly
      include Generators::Hobo::Taglib

      class_option :make_front_site,
                 :type => :boolean,
                 :desc => "Rename application.dryml to front_site.dryml"

      # check_class_collision :suffix => 'SiteController'

      def move_and_generate_files
        if options[:make_front_site]
          unless can_mv_application_to_front_site?
            say "Cannot rename application.dryml to #{file_name}_site.dryml"
            exit 1
          end
          say "Renaming app/views/taglibs/application.dryml to app/views/taglibs/front_site.dryml" \
              unless options[:quiet]
          unless options[:pretend]
            FileUtils.mv('app/views/taglibs/application.dryml', "app/views/taglibs/front_site.dryml")
            copy_file "application.dryml", 'app/views/taglibs/application.dryml'
          end
        end

        template "controller.rb.erb", File.join('app/controllers', file_name, "#{file_name}_site_controller.rb")
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
