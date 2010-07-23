module Hobo
    class ModelGenerator < Rails::Generators::NamedBase

    source_root File.expand_path('../templates', __FILE__)

    class_option :timestamps,
                 :type => :boolean,
                 :default => true,
                 :desc => "Add timestamps to the migration file for this model. Skip with '--no-timestamps'"

    class_option :fixture,
                 :type => :boolean,
                 :default => true,
                 :desc => "Generate a fixture file for this model. Skip with '--no-fixture'"

    argument :attributes,
             :type => :string,
             :default => ''

    def create_stubs
      # Check for class naming collisions.
      class_collisions class_path, class_name, "#{class_name}Test"

      # Create stubs
      template "model.rb.erb",  File.join("app/models", class_path, "#{file_name}.rb")
      template "test.rb.erb",   File.join("test/unit", class_path, "#{file_name}_test.rb")

      unless options[:skip_fixture]
       	template 'fixtures.yml.erb',  File.join('test/fixtures', "#{file_name.pluralize}.yml")
      end
    end

  end
end
