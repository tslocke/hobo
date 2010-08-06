module Hobo
  Generators::ControllerModule = classy_module do

    check_class_collision :suffix => 'Controller'

    def self.banner
      "rails generate hobo:controller #{self.arguments.map(&:usage).join(' ')}"
    end

    def generate_controller
      if class_path.length == 1 and
        subsite = class_path.first and
        File.exist?(File.join('app/controllers', class_path, "#{subsite}_site_controller.rb"))
        @subsite = subsite.camelize
      end
      template 'controller.rb.erb', File.join('app/controllers',"#{file_path}_controller.rb")
    end

    def generate_helper
      invoke 'helper', [name], options
    end

    hook_for :test_framework, :as => :controller

  end
end
