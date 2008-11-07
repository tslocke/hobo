class HoboGenerator < Rails::Generator::Base

  def manifest
    if options[:add_routes]
      routes_path = File.join(RAILS_ROOT, "config/routes.rb")

      route = "  Hobo.add_routes(map)\n"
      route_src = File.read(routes_path)
      unless route_src.include?(route)
        head = "ActionController::Routing::Routes.draw do |map|"
        route_src.sub!(head, head + "\n\n" + route)
        File.open(routes_path, 'w') {|f| f.write(route_src) }
      end
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
      m.file "patch_routing.rb",      File.join("config/initializers/patch_routing.rb")
    end
  end

  protected
    def banner
      "Usage: #{$0} #{spec.name} [--add-routes]"
    end

    def add_options!(opt)
      opt.separator ''
      opt.separator 'Options:'
      opt.on("--add-routes",
             "Add Hobo routes to config/routes.rb") { |v| options[:add_routes] = v }
    end
end
