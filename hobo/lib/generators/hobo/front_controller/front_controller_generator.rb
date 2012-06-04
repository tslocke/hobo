module Hobo
  class FrontControllerGenerator < Rails::Generators::NamedBase
    source_root File.expand_path('../templates', __FILE__)

    # overrides the default
    argument :name, :type => :string, :default => 'front', :optional => true

    include Generators::Hobo::Controller
    include Generators::Hobo::InviteOnly

    def self.banner
      "rails generate hobo:front_controller [NAME=front] [options]"
    end

    class_option :add_routes,
                 :type => :boolean,
                 :desc => "Modify config/routes.rb to support the front controller",
                 :default => true

    class_option :delete_index,
                 :aliases => '-d',
                 :type => :boolean,
                 :desc => "Delete public/index.html",
                 :default => true

    class_option :user_resource_name,
                 :type => :string,
                 :desc => "User Resource Name",
                 :default => 'user'

    def generate_controller
      template 'controller.rb.erb', File.join('app/controllers',"#{file_path}_controller.rb")
    end

    def generate_index
      template("index.dryml", File.join('app/views', file_path, "index.dryml"))
    end

    def remove_index_html
      return unless options[:delete_index]
      remove_file File.join(Rails.root, "public/index.html")
    end

    def add_routes
      return unless options[:add_routes]
      route "match 'search' => '#{file_path}#search', :as => 'site_search'"
      if class_path.empty?
        route "root :to => '#{file_path}#index'"
        route "match ENV['RAILS_RELATIVE_URL_ROOT'] => 'front#index' if ENV['RAILS_RELATIVE_URL_ROOT']"
      else
        route "match '#{file_path}' => '#{file_path}#index', :as => '#{file_path.gsub(/\//,'_')}'"
      end
    end

  end
end
