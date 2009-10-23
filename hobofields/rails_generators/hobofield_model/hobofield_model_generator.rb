class HobofieldModelGenerator < Rails::Generator::NamedBase
  default_options :skip_timestamps => false, :skip_fixture => false

  def manifest
    record do |m|
      # Check for class naming collisions.
      m.class_collisions class_path, class_name, "#{class_name}Test"

      # Model, test, and fixture directories.
      m.directory File.join('app/models', class_path)
      m.directory File.join('test/unit', class_path)
      m.directory File.join('test/fixtures', class_path)

      # Create stubs
      m.template "model.rb.erb",  "app/models/#{file_name}.rb"
      m.template "test.rb.erb",   "test/unit/#{file_name}_test.rb"

      unless options[:skip_fixture]
       	m.template 'fixtures.yml.erb',  File.join('test/fixtures', "#{file_name.pluralize}.yml")
      end

    end
  end

  protected
    def banner
      "Usage: #{$0} #{spec.name} ModelName [field:type, field:type]"
    end

    def add_options!(opt)
      opt.separator ''
      opt.separator 'Options:'
      opt.on("--skip-timestamps",
             "Don't add timestamps to the migration file for this model") { |v| options[:skip_timestamps] = v }
      opt.on("--skip-fixture",
             "Don't generate a fixture file for this model") { |v| options[:skip_fixture] = v}
    end
end
