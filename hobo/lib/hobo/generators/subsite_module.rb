require 'fileutils'
module Hobo
  Generators::SubsiteModule = classy_module do

    class_option :make_front_site,
                 :type => :boolean,
                 :desc => "Rename application.dryml to front_site.dryml"

    class_option :rapid,
                 :type => :boolean,
                 :desc => "Include Rapid features in the subsite taglib",
                 :default => true

    check_class_collision :suffix => 'SiteController'

    def move_and_generate_files
      if options[:make_front_site]
        unless can_mv_application_to_front_site?
          say "Cannot rename application.dryml to #{file_name}_site.dryml"
          exit 1
        end
        say "Renaming app/views/taglibs/application.dryml to app/views/taglibs/#{file_name}site.dryml"
        FileUtils.mv('app/views/taglibs/application.dryml', "app/views/taglibs/#{file_name}.dryml")
        template "application.dryml", 'app/views/taglibs/application.dryml'
      end

      template "controller.rb.erb", File.join('app/controllers', file_name, "#{file_name}_site_controller.rb")
      template "site_taglib.dryml", File.join('app/views/taglibs', "#{file_name}_site.dryml")
    end

    hook_for :test_framework, :as => :controller do | instance, controller_test |
      instance.invoke controller_test, ["#{instance.name}_site"]
    end

  private

    def subsite_name
      class_name
    end

    def app_name
      front_name = File.read('app/views/taglibs/front_site.dryml').grep(%r(<def tag="app-name">(.*)</def>)){ $1 } rescue nil
      front_name ? "#{front_name} - #{subsite_name.titleize}" : subsite_name.titleize
    end

    def can_mv_application_to_front_site?
      File.exist?('app/views/taglibs/application.dryml') && !File.exist?('app/views/taglibs/front_site.dryml')
    end

  end
end
