class HoboModelGenerator < Rails::Generator::NamedBase

  def manifest
    record do |m|
      # Check for class naming collisions.
      m.class_collisions class_path, class_name, "#{class_name}Test"

      # Model, test, and fixture directories.
      m.directory File.join('app/models', class_path)
      m.directory File.join('test/unit', class_path)
      m.directory File.join('test/fixtures', class_path)
      m.directory File.join("app/viewhints")

      # Model class, unit test, and fixtures.
      m.template 'model.rb',      File.join('app/models',    class_path, "#{file_name}.rb")
      m.template 'hints.rb',      File.join('app/viewhints', class_path, "#{file_name}_hints.rb")
      m.template 'unit_test.rb',  File.join('test/unit',     class_path, "#{file_name}_test.rb")
      m.template 'fixtures.yml',  File.join('test/fixtures', class_path, "#{table_name}.yml")
    end
  end

  protected
    def banner
      "Usage: #{$0} #{spec.name} ModelName [field:type, field:type]"
    end
    
    def max_attribute_length
      attributes.*.name.*.length.max
    end

end
