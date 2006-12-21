
def add_route
  routes_path = File.join(RAILS_ROOT, "config/routes.rb")

  route = "  Hobo.add_routes(map)\n"

  route_src = File.read(routes_path)
  return if route_src.include?(route)

  print 'Add Hobo routes to config/routes.rb? (recommended) [yN] '
  return unless STDIN.readline.strip == 'y'

  head = "ActionController::Routing::Routes.draw do |map|"
  route_src.sub!(head, head + "\n\n" + route)
  File.open(routes_path, 'w') {|f| f.write(route_src) }
end

add_route

