class HoboFrontControllerGenerator < Rails::Generator::NamedBase

  default_options :delete_index => false, :add_routes => false

  def full_class_path
    class_path.blank? ? file_name : File.join(class_path, file_name)
  end

  def manifest
    if options[:command] == :create
      add_routes if options[:add_routes]
      remove_index_html if options[:delete_index]
    end

    record do |m|
      # Check for class naming collisions.
      m.class_collisions(class_path, "#{class_name}Controller",
                         "#{class_name}ControllerTest", "#{class_name}Helper")

      # Controller, helper, views, and test directories.
      m.directory File.join('app/controllers', class_path)
      m.directory File.join('app/helpers', class_path)
      m.directory File.join('app/views', class_path, file_name)
      m.directory File.join('test/functional', class_path)

      # Controller class, functional test, and helper class.
      m.template('controller.rb',
                 File.join('app/controllers', class_path, "#{file_name}_controller.rb"))

      m.template('functional_test.rb',
                 File.join('test/functional', class_path, "#{file_name}_controller_test.rb"))

      m.template('helper.rb',
                 File.join('app/helpers', class_path, "#{file_name}_helper.rb"))


      m.template("index.dryml", File.join('app/views', class_path, file_name, "index.dryml"))
    end
  end

  def app_name
    @app_name ||= File.basename(Dir.chdir(RAILS_ROOT) { Dir.getwd }).strip.titleize
  end

  def add_routes
    routes_path = File.join(RAILS_ROOT, "config/routes.rb")
    name = full_class_path

    route = ("  map.site_search  'search', :controller => '#{name}', :action => 'search'\n" +
             "  map.root :controller => '#{name}', :action => 'index'")

    route_src = File.read(routes_path)
    return if route_src.include?(route)

    head = "ActionController::Routing::Routes.draw do |map|"
    route_src.sub!(head, head + "\n\n" + route)
    File.open(routes_path, 'w') {|f| f.write(route_src) }
  end

  def remove_index_html
    index_path = File.join(RAILS_ROOT, "public/index.html")
    return unless File.exists?(index_path)
    File.unlink(index_path)
  end

  protected
    def banner
      "Usage: #{$0} #{spec.name} <controller-name> [--add-routes] [--delete-index]"
    end

    def add_options!(opt)
      opt.separator ''
      opt.separator 'Options:'
      opt.on("--add-routes",
             "Modify config/routes.rb to support the front controller") { |v| options[:add_routes] = true }
      opt.on("--delete-index",
             "Delete public/index.html") { |v| options[:delete_index] = true }
    end

end
