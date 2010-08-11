module Hobo
  class RoutesGenerator < Rails::Generators::Base
    source_root File.expand_path('../templates', __FILE__)

    def self.banner
      "rails generate hobo:routes #{self.arguments.map(&:usage).join(' ')} [options]"
    end

    def generate_routes
      Hobo::Routes.reset_linkables
      template "hobo_routes.rb.erb", Hobo::Engine.config.hobo.routes_path
    end

private

    def subsites
      [nil, *Hobo.subsites]
    end

    def controllers_for(subsite)
      Hobo::ModelController.all_controllers(subsite, :force).select { |c| c < Hobo::ModelController }
    end

    def router_for(subsite, controller)
      Hobo::Router.new(subsite, controller)
    end

  end
end
