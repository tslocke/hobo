module Generators
  module Hobo
    Controller = classy_module do

      # check_class_collision :suffix => 'Controller'

      class_option :helpers, :type => :boolean,
      :desc => "Generates helper files",
      :default => !Rails.application.config.hobo.dryml_only_templates

      def self.banner
      "rails generate hobo:controller #{self.arguments.map(&:usage).join(' ')}"
      end

      def generate_controller
        if class_path.length == 1 and
          subsite = class_path.first and
	  (
	    options[:subsite_controller_is_being_created] or 
            File.exist?(File.join('app/controllers', class_path, "#{subsite}_site_controller.rb"))
          )
          @subsite = subsite.camelize
        end
        template 'controller.rb.erb', File.join('app/controllers',"#{file_path}_controller.rb")
      end

      def generate_helper
        return unless options[:helpers]
        invoke 'helper', [name], options
      end

      hook_for :test_framework, :as => :controller do | instance, controller_test |
        instance.invoke controller_test, [ instance.name ]
      end

    end
  end
end
