class HoboUserModelGenerator < Rails::Generator::NamedBase

  def manifest
    record do |m|
      # Check for class naming collisions.
      m.class_collisions class_path, class_name, "#{class_name}Test"

      # Model, test, and fixture directories.
      m.directory File.join('app/models', class_path)
      m.directory File.join('test/unit', class_path)
      m.directory File.join('test/fixtures', class_path)

      # Model class, unit test, and fixtures.
      m.template 'model.rb',            File.join('app/models', class_path, "#{file_name}.rb")
      m.template 'mailer.erb',          File.join('app/models', class_path, "#{file_name}_mailer.rb")
      m.template 'forgot_password.erb', File.join('app/views/#{file_name}', class_path, "forgot_password.erb")
      m.template 'unit_test.rb',        File.join('test/unit', class_path, "#{file_name}_test.rb")
      m.template 'fixtures.yml',        File.join('test/fixtures', class_path, "#{table_name}.yml")
    end
  end

  protected
    def banner
      "Usage: #{$0} #{spec.name} ModelName"
    end

end
