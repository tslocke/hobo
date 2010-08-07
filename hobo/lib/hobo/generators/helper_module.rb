module Hobo
  Generators::HelperModule = classy_module do

    # Tries to retrieve the application name or simple return application.
    def application_name
      if defined?(Rails) && Rails.application
        Rails.application.class.name.split('::').first.underscore
      else
        "application"
      end
    end

  end
end
