class HoboModelControllerGenerator < Rails::Generator::NamedBase

  def initialize(args, options)
    args[0] = args[0].pluralize
    super(args, options)
  end
  
  attr_reader :subsite

  def manifest
    record do |m|
      # Check for class naming collisions.
      m.class_collisions class_path, "#{class_name}Controller", "#{class_name}ControllerTest", "#{class_name}Helper"
      
      if class_path.length == 1 and
        subsite = class_path.first and
        File.exist?(File.join('app/controllers', class_path, "#{subsite}_site_controller.rb"))
        
        @subsite = subsite.camelize
      end

      # Controller, helper, views, and test directories.
      m.directory File.join('app/controllers', class_path)
      m.directory File.join('app/helpers', class_path)
      m.directory File.join('app/views', class_path, file_name)
      m.directory File.join('test/functional', class_path)

      # Controller class, functional test, and helper class.
      m.template 'controller.rb',
                  File.join('app/controllers',
                            class_path,
                            "#{file_name}_controller.rb")

      m.template 'functional_test.rb',
                  File.join('test/functional',
                            class_path,
                            "#{file_name}_controller_test.rb")

      m.template 'helper.rb',
                  File.join('app/helpers',
                            class_path,
                            "#{file_name}_helper.rb")
    end
  end

end
