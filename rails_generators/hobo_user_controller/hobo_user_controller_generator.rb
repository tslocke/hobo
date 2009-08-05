class HoboUserControllerGenerator < Rails::Generator::NamedBase

  def initialize(args, options)
    args[0] = args[0].pluralize
    super(args, options)
  end

  def manifest
    record do |m|
      # Check for class naming collisions.
      m.class_collisions class_path, "#{class_name}Controller", "#{class_name}ControllerTest", "#{class_name}Helper"

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

      # View template for each action.
      actions.each do |action|
        path = File.join('app/views', class_path, file_name, "#{action}.rhtml")
        m.template 'view.rhtml', path,
          :assigns => { :action => action, :path => path }
      end
      
      if invite_only?
        m.template "accept_invitation.dryml", File.join('app/views', class_path, file_name, "accept_invitation.dryml")
      end
    end
  end
  
  def invite_only?
    options[:invite_only]
  end

  protected
    def banner
      "Usage: #{$0} #{spec.name} ModelName [--invite-only]"
    end
    
    def add_options!(opt)
      opt.separator ''
      opt.separator 'Options:'
      opt.on("--invite-only", "Add features for an invite only website") do |v|
        options[:invite_only] = true
      end
    end    
  
end
