class HoboGenerator < Rails::Generator::Base

  def manifest
    if options[:add_gem]
      add_to_file "config/environment.rb", "Rails::Initializer.run do |config|", "  config.gem 'hobo'\n"
      add_to_file "Rakefile", "require 'tasks/rails'", "\nrequire 'hobo/tasks/rails'"
    end
    
    if options[:add_routes]
      add_to_file "config/routes.rb", "ActionController::Routing::Routes.draw do |map|", "\n  Hobo.add_routes(map)\n"
    end

    record do |m|
      m.directory                     File.join("app/views/taglibs")
      m.directory                     File.join("app/views/taglibs/themes")
      m.template "application.dryml", File.join("app/views/taglibs/application.dryml")
      m.directory                     File.join("public/hobothemes")

      m.directory                     File.join("app/models")
      m.file "guest.rb",              File.join("app/models/guest.rb")

      m.directory                     File.join("public/stylesheets")
      m.file "application.css",       File.join("public/stylesheets/application.css")
      m.file "dryml-support.js",      File.join("public/javascripts/dryml-support.js")

      m.file "initializer.rb",        File.join("config/initializers/hobo.rb")
    end
  end
  
  protected
    def banner
      "Usage: #{$0} #{spec.name} [--add-routes] [--add-gem]"
    end

    def add_options!(opt)
      opt.separator ''
      opt.separator 'Options:'
      opt.on("--add-routes",
             "Add Hobo routes to config/routes.rb") { |v| options[:add_routes] = v }
      opt.on("--add-gem",
             "Edit environment.rb to require the hobo gem") { |v| options[:add_gem] = v }
    end
    
    def add_to_file(filename, after_line, new_line)
      filename = File.join(RAILS_ROOT, filename)
      src = File.read filename
      unless src.include? new_line
        src.sub!(after_line, after_line + "\n" + new_line)
        File.open(filename, 'w') {|f| f.write(src) }
      end
    end

end
