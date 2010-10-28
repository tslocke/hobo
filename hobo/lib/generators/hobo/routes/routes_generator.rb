require 'generators/hobo_support/eval_template'

module Hobo
  class RoutesGenerator < Rails::Generators::Base
    source_root File.expand_path('../templates', __FILE__)

    include Generators::HoboSupport::EvalTemplate

    def self.banner
      "rails generate hobo:routes #{self.arguments.map(&:usage).join(' ')} [options]"
    end

    def generate_routes
      Hobo::Routes.reset_linkables
      h = Hobo::Engine.config.hobo
      template_name = 'hobo_routes.rb.erb'
      if h.read_only_file_system
        # just fill the @linkable_keys without writing any file
        eval_template template_name
      else
        template template_name, h.routes_path
      end
    end

private

    def subsites
      [nil, *Hobo.subsites]
    end

    def controllers_for(subsite)
      Hobo::Controller::Model.all_controllers(subsite, :force).select { |c| c < Hobo::Controller::Model }
    end

    def router_for(subsite, controller)
      Generators::Hobo::Routes::Router.new(subsite, controller)
    end

  end
end
