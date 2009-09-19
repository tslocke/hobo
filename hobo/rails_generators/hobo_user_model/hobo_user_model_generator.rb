class HoboUserModelGenerator < Rails::Generator::NamedBase

  def manifest
    record do |m|
      # Check for class naming collisions.
      m.class_collisions class_path, class_name, "#{class_name}Test"

      # Model, test, and fixture directories.
      m.directory File.join('app/models', class_path)
      m.directory File.join('test/unit', class_path)
      m.directory File.join('test/fixtures', class_path)
      mailer_dir = File.join("app/views", class_path[0..-2], "#{file_name.singularize}_mailer")
      m.directory mailer_dir

      # Model class, unit test, and fixtures.
      m.template 'model.rb',            File.join('app/models',    class_path, "#{file_name}.rb")
      m.template 'unit_test.rb',        File.join('test/unit',     class_path, "#{file_name}_test.rb")
      m.template 'fixtures.yml',        File.join('test/fixtures', class_path, "#{table_name}.yml")

      m.template 'mailer.rb',           File.join('app/models', class_path, "#{file_name}_mailer.rb")
      m.template 'forgot_password.erb', File.join(mailer_dir, "forgot_password.erb")
      
      if invite_only?
        m.template 'invite.erb', File.join(mailer_dir, "invite.erb")
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
