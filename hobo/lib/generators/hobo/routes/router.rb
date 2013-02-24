module Generators
  module Hobo
    module Routes
      class Router

        # specify that an id CANNOT be null - needed to disambiguate /models from /models/[nil]
        ID_REQUIREMENT = "{ :id => %r([^#{ActionController::Routing::SEPARATORS.join}]+) }"

        attr_reader :subsite, :controller, :model, :record, :records

        def initialize(subsite, controller)
          raise ::Hobo::Error, "#{controller} is not a Hobo::Controller::Model" unless controller < ::Hobo::Controller::Model
          @subsite = subsite
          @controller = controller
          @model = controller.model
          @records = controller.controller_name
          @record = @records.singularize
        end

        def emit_hash(hash, prefix)
          s = ""
          hash.each do |key, val|
            s << "#{prefix}#{key}"
            unless val.blank?
              s << " do\n"
              val.each do |sub|
                if sub.is_a?(Hash)
                  s << emit_hash(sub, prefix + "  ")
                else
                  s << "#{prefix}  #{sub}\n"
                end
              end
              s << "#{prefix}end\n"
            else
              s << "\n"
            end
          end
          s
        end

        def resources_hash
          collections = []
          collections += index_actions
          collections += lifecycle_collection_actions
          collections << "post 'reorder'" if controller.public_method_defined?(:reorder)
          members = []
          members += show_actions
          members += web_methods
          members += lifecycle_member_actions
          right = []
          right << {"collection" => collections} unless collections.blank?
          right << {"member" => members} unless members.blank?
          {basic_resources => right}
        end

        def basic_resources
          actions = %w(index new edit show create update destroy).select {|action| controller.public_method_defined?(action)}
          if actions.length == 7
            "resources :#{records}"
          else
            "resources :#{records}, :only => [#{actions.map{|a| ':'+a}.join(', ')}]"
          end
        end

        def index_actions
          controller.index_actions.map do |action|
            "get '#{action}'"
          end
        end

        def show_actions
          controller.show_actions.map do |action|
            "get '#{action}'"
          end
        end

        def lifecycle_collection_actions
          return [] unless defined? model::Lifecycle
          model::Lifecycle.creators.values.where.routable_for?(@subsite).*.name.map do |creator|
            ["post '#{creator}', :action => 'do_#{creator}'",
             "get '#{creator}'" ]
          end.flatten
        end

        def lifecycle_member_actions
          return [] unless defined? model::Lifecycle
          model::Lifecycle.transitions.where.routable_for?(@subsite).*.name.map do |transition|
            ["put '#{transition}', :action => 'do_#{transition}'",
             "get '#{transition}'"]
          end.flatten
        end

        def web_methods
          controller.web_methods.map do |action|
            "post '#{action}'"
          end
        end

        def owner_actions
          controller.owner_actions.map do |owner, actions|
            collection_refl = model.reverse_reflection(owner)
            raise ::Hobo::Error, "Hob routing error -- can't find reverse association for #{model}##{owner} " +
                             "(e.g. the :has_many that corresponds to a :belongs_to)" if collection_refl.nil?
            collection         = collection_refl.name
            owner_class        = model.reflections[owner].klass.name.underscore
            owner = owner.to_s.singularize if model.reflections[owner].macro == :has_many
            collection_path = "#{owner_class.pluralize}/:#{owner}_id/#{collection}"

            routes = []
            routes << "get 'new', :on => :new, :action => 'new_for_#{owner}'" if actions.include?(:new)
            collection_routes = []
            collection_routes << "get 'index', :action => 'index_for_#{owner}'" if actions.include?(:index)
            collection_routes << "post 'create', :action => 'create_for_#{owner}'" if actions.include?(:create)
            routes << {"collection" => collection_routes} unless collection_routes.empty?

            { "resources :#{owner_class.pluralize}, :as => :#{owner}, :only => []" =>
              [ "resources :#{collection}, :only => []" => routes]
            }
          end
        end

        def emit_resources
          "# #{@resource_hash.inspect}\n"+
          "# #{owner_actions.inspect}"
        end

        # deprecated
        def index_action_routes
          controller.index_actions.map do |action|
            link( "get '#{records}/#{action}(.:format)', :as => '#{action}_#{records}'", action )
          end.compact
        end

        # deprecated
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
          routes.compact.uniq
        end

        # deprecated
        def resource_routes
          [
          link("get '#{records}(.:format)' => '#{records}#index', :as => '#{records}'", 'index'),
          link("get '#{records}/new(.:format)' => '#{records}#new', :as => 'new_#{record}'", 'new'),
          link("get '#{records}/:id/edit(.:format)' => '#{records}#edit', :as => 'edit_#{record}'", 'edit'),
          link("get '#{records}/:id(.:format)' => '#{records}#show', :as => '#{record}', :constraints => #{ID_REQUIREMENT}", 'show'),
          link("post '#{records}(.:format)' => '#{records}#create', :as => 'create_#{record}'", 'create', :post),
          link("put '#{records}/:id(.:format)' => '#{records}#update', :as => 'update_#{record}', :constraints => #{ID_REQUIREMENT}", 'update', :put),
          link("delete '#{records}/:id(.:format)' => '#{records}#destroy', :as => 'destroy_#{record}', :constraints => #{ID_REQUIREMENT}", 'destroy', :delete)
          ].compact
        end

        # deprecated
        def owner_routes
          routes = []
          controller.owner_actions.each_pair do |owner, actions|
            collection_refl = model.reverse_reflection(owner)
            raise ::Hobo::Error, "Hob routing error -- can't find reverse association for #{model}##{owner} " +
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

        # deprecated
        def web_method_routes
          controller.web_methods.map do |action|
            link("post '#{records}/:id/#{action}(.:format)' => '#{records}##{action}', :as => '#{record}_#{action}'", action, :post)
          end.compact
        end

        # deprecated
        def show_action_routes
          controller.show_actions.map do |action|
            link("get '#{records}/:id/#{action}(.:format)' => '#{records}##{action}', :as => '#{record}_#{action}'", action)
          end.compact
        end

        # deprecated
        def reorder_routes
          [ link("post '#{records}/reorder(.:format)', :as => 'reorder_#{records}'", 'reorder', :post) ].compact
        end

        # NOT deprecated
        def user_routes
          return [] unless controller < ::Hobo::Controller::UserBase
          prefix = records == "users" ? "" : "#{record}_"
          [
          link("get '#{prefix}login(.:format)' => '#{records}#login', :as => '#{record}_login'",  'login'),
          link("get '#{prefix}logout(.:format)' => '#{records}#logout', :as => '#{record}_logout'",  'logout'),
          link("get '#{prefix}forgot_password(.:format)' => '#{records}#forgot_password', :as => '#{record}_forgot_password'",  'forgot_password'),
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
