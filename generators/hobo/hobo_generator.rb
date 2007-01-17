class HoboGenerator < Rails::Generator::Base

  def manifest
    if options[:add_routes]
      routes_path = File.join(RAILS_ROOT, "config/routes.rb")

      route = "  Hobo.add_routes(map)\n"

      route_src = File.read(routes_path)
      return if route_src.include?(route)

      head = "ActionController::Routing::Routes.draw do |map|"
      route_src.sub!(head, head + "\n\n" + route)
      File.open(routes_path, 'w') {|f| f.write(route_src) }
    end

    record do |m|
      m.directory File.join("app/views/hobolib")
      m.directory File.join("app/views/hobolib/themes")
      m.directory File.join("public/hobothemes")
      m.file "application.dryml", File.join("app/views/hobolib/application.dryml")
      m.file "guest.rb", File.join("app/models/guest.rb")
    end
  end

  protected
    def banner
      "Usage: #{$0} generate [--add-routes]"
    end

    def add_options!(opt)
      opt.separator ''
      opt.separator 'Options:'
      opt.on("--add-routes",
             "Add Hobo routes to config/routes.rb") { |v| options[:add_routes] = v }
    end
end
