module Generators
  module Hobo
    module Routes
      class Router

        # specify that an id CANNOT be null - needed to disambiguate /models from /models/[nil]
        ID_REQUIREMENT = "{ :id => %r([^#{ActionController::Routing::SEPARATORS.join}]+) }"

        attr_reader :subsite, :controller, :model, :record, :records

        def initialize(subsite, controller)
          raise "#{controller} is not a Hobo::Controller::Model" unless controller < ::Hobo::Controller::Model
          @subsite = subsite
          @controller = controller
          @model = controller.model
          @records = controller.controller_name
          @record = @records.singularize
        end

        def index_action_routes
          controller.index_actions.map do |action|
            link( "get '#{records}/#{action}(.:format)', :as => '#{action}_#{records}'", action )
          end.compact
        end

        def lifecycle_routes(subsite)
          return [] unless defined? model::Lifecycle
          routes = []
          model::Lifecycle.creators.values.where.routable_for?(subsite).*.name.each do |creator|
            routes << link("post '#{records}/#{creator}(.:format)' => '#{records}#do_#{creator}', :as => 'do_#{record}_#{creator}'", creator, :post)
            routes << link("get '#{records}/#{creator}(.:format)' => '#{records}##{creator}', :as => '#{record}_#{creator}'", creator)
          end
          model::Lifecycle.transitions.where.routable_for?(subsite).*.name.each do |transition|
            routes << link("put '#{records}/:id/#{transition}(.:format)' => '#{records}#do_#{transition}', :as => 'do_#{record}_#{transition}'", transition, :put)
            routes << link("get '#{records}/:id/#{transition}(.:format)' => '#{records}##{transition}', :as => '#{record}_#{transition}'", transition)
          end
          routes.compact
        end

        def resource_routes
          [
          link("get '#{records}(.:format)' => '#{records}#index', :as => '#{records}'", 'index'),
          link("get '#{records}/new(.:format)', :as => 'new_#{record}'", 'new'),
          link("get '#{records}/:id/edit(.:format)' => '#{records}#edit', :as => 'edit_#{record}'", 'edit'),
          link("get '#{records}/:id(.:format)' => '#{records}#show', :as => '#{record}', :constraints => #{ID_REQUIREMENT}", 'show'),
          link("post '#{records}(.:format)' => '#{records}#create', :as => 'create_#{record}'", 'create', :post),
          link("put '#{records}/:id(.:format)' => '#{records}#update', :as => 'update_#{record}', :constraints => #{ID_REQUIREMENT}", 'update', :put),
          link("delete '#{records}/:id(.:format)' => '#{records}#destroy', :as => 'destroy_#{record}', :constraints => #{ID_REQUIREMENT}", 'destroy', :delete)
          ].compact
        end

        def owner_routes
          routes = []
          controller.owner_actions.each_pair do |owner, actions|
            collection_refl = model.reverse_reflection(owner)
            raise Hobo::Error, "Hob routing error -- can't find reverse association for #{model}##{owner} " +
                             "(e.g. the :has_many that corresponds to a :belongs_to)" if collection_refl.nil?
            collection         = collection_refl.name
            owner_class        = model.reflections[owner].klass.name.underscore
            owner = owner.to_s.singularize if model.reflections[owner].macro == :has_many
            collection_path = "#{owner_class.pluralize}/:#{owner}_id/#{collection}"

            actions.each do |action|
              action_for_owner = "#{action}_for_#{owner}"
              case action
              when :index
                routes << link("get '#{collection_path}(.:format)' => '#{records}##{action_for_owner}', :as => '#{records}_for_#{owner}'", action_for_owner)
              when :new
                routes << link("get '#{collection_path}/new(.:format)' => '#{records}##{action_for_owner}', :as => 'new_#{record}_for_#{owner}'", action_for_owner)
              when :create
                routes << link("post '#{collection_path}(.:format)' => '#{records}##{action_for_owner}', :as => 'create_#{record}_for_#{owner}'", action_for_owner, :post)
              end
            end
          end
          routes.compact
        end

        def web_method_routes
          controller.web_methods.map do |action|
            link("post '#{records}/:id/#{action}(.:format)' => '#{records}##{action}', :as => '#{record}_#{action}'", action, :post)
          end.compact
        end

        def show_action_routes
          controller.show_actions.map do |action|
            link("get '#{records}/:id/#{action}(.:format)' => '#{records}##{action}', :as => '#{record}_#{action}'", action)
          end.compact
        end

        def reorder_routes
          [ link("post '#{records}/reorder(.:format)', :as => 'reorder_#{records}'", 'reorder', :post) ].compact
        end

        def user_routes
          return [] unless controller < ::Hobo::Controller::User
          prefix = records == "users" ? "" : "#{record}_"
          [
          link("match '#{prefix}login(.:format)' => '#{records}#login', :as => '#{record}_login'",  'login'),
          link("get '#{prefix}logout(.:format)' => '#{records}#logout', :as => '#{record}_logout'",  'logout'),
          link("match '#{prefix}forgot_password(.:format)' => '#{records}#forgot_password', :as => '#{record}_forgot_password'",  'forgot_password'),
          ].compact
        end

      private

        def link(route, action, method=:get)
          return unless controller.public_method_defined?(action)
          ::Hobo::Routes.linkable!( model, action, :subsite => subsite, :method => method )
          route
        end

      end
    end
  end
end
