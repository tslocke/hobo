if defined? ActionController::Routing::RouteSet

  class ActionController::Routing::RouteSet
    # Monkey patch this method so routes are reloaded on *every*
    # request. Without this Rails checks the mtime of config/routes.rb
    # which doesn't take into account Hobo's auto routing
    #def reload
    #  # TODO: This can get slow - quicker to stat routes.rb and the
    #  # controllers and only do a load if there's been a change
    #  load!
    #end

    # temporay hack -- reload assemble.rb whenever routes need reloading
    def reload_with_hobo_assemble
      if defined? ::ApplicationController
        load "#{RAILS_ROOT}/app/assemble.rb" if File.exists? "#{RAILS_ROOT}/app/assemble.rb"
      end
      reload_without_hobo_assemble
    end
    alias_method_chain :reload, :hobo_assemble

  end

end

module Hobo

  class ModelRouter

    APP_ROOT = "#{RAILS_ROOT}/app"

    class << self

      def reset_linkables
        @linkable =Set.new
      end

      def linkable_key(klass, action, options)
        subsite = options[:subsite] || options['subsite']
        method  = options[:method]  || options['method']
        opts = options.map { |k, v| "#{k}=#{v}" unless v.blank? }.compact.join(',')
        "#{subsite}/#{klass.name}/#{action}/#{method}"
      end

      def linkable!(klass, action, options={})
        options[:method] ||= :get
        @linkable << linkable_key(klass, action, options)
      end

      def linkable?(klass, action, options={})
        options[:method] ||= :get
        @linkable.member? linkable_key(klass, action, options)
      end

      def add_routes(map)
        reset_linkables

        begin
          ActiveRecord::Base.connection.reconnect! unless ActiveRecord::Base.connection.active?
        rescue
          # No database, no routes
          return
        end

        require "#{APP_ROOT}/controllers/application" unless Object.const_defined? :ApplicationController
        load "#{APP_ROOT}/assemble.rb" if File.exists? "#{APP_ROOT}/assemble.rb"

        # Don't create routes if it's a generator that's running
        return if caller[-1] =~ /script[\/\\]generate:\d+$/

        # Add non-subsite routes
        add_routes_for(map, nil)

        # Any directory inside app/controllers defines a subsite
        subsites = Dir["#{APP_ROOT}/controllers/*"].map { |f| File.basename(f) if File.directory?(f) }.compact
        subsites.each { |subsite| add_routes_for(map, subsite) }

        add_developer_routes(map) if Hobo.developer_features?
      rescue ActiveRecord::StatementInvalid
        # Database problem? Just continue without routes
      end


      def add_routes_for(map, subsite)
        module_name = subsite._?.camelize

        # FIXME: This should go directly to the controllers, not load the models first.
        Hobo.models.each do |model|
          controller_name = "#{model.name.pluralize}Controller"
          is_defined = if subsite
                         Object.const_defined?(module_name) && module_name.constantize.const_defined?(controller_name)
                       else
                         Object.const_defined?(controller_name)
                       end
          controller_filename = File.join(*["#{APP_ROOT}/controllers", subsite, "#{controller_name.underscore}.rb"].compact)
          if is_defined || File.exists?(controller_filename)
            controller = (subsite ? "#{module_name}::#{controller_name}" : controller_name).constantize
            ModelRouter.new(map, model, controller, subsite)
          end
        end
      end


      def add_developer_routes(map)
        map.dryml_support "dryml/:action", :controller => "hobo/dryml/dryml_support"
        map.dev_support   "dev/:action",   :controller => "hobo/dev"
      end

    end


    def initialize(map, model, controller, subsite)
      @map = map
      @model = model
      @controller = controller
      @subsite = subsite
      add_routes
    end


    attr_reader :map, :model, :controller, :subsite


    def plural
      model.name.underscore.pluralize
    end


    def singular
      model.name.underscore
    end


    def add_routes
      # Simple support for composite models, we might later need a CompositeModelController
      if model < Hobo::CompositeModel
        map.connect "#{plural}/:id", :controller => plural, :action => 'show'

      elsif controller < Hobo::ModelController
        # index routes need to be first so the index names don't get
        # taken as IDs
        index_action_routes
        lifecycle_routes if defined? model::Lifecycle
        resource_routes
        collection_routes
        web_method_routes
        show_action_routes
        
        reorder_route
        user_routes      if controller < Hobo::UserController
      end
    end


    def resource_routes
      # We re-implement resource routing - routes are not created for
      # actions that the controller does not provide

      # FIX ME -- what about routes with formats (e.g. .xml)?

      linkable_route(plural, plural, :index, :conditions => { :method => :get })

      linkable_route("new_#{singular}",  "#{plural}/new",      :new,  :conditions => { :method => :get })
      linkable_route("edit_#{singular}", "#{plural}/:id/edit", :edit, :conditions => { :method => :get })

      linkable_route(singular, "#{plural}/:id", :show, :conditions => { :method => :get })

      linkable_route("create_#{singular}",  plural,          :create,  :conditions => { :method => :post })
      linkable_route("update_#{singular}",  "#{plural}/:id", :update,  :conditions => { :method => :put })
      linkable_route("destroy_#{singular}", "#{plural}/:id", :destroy, :conditions => { :method => :delete })
    end


    def collection_routes
      controller.collections.each do |collection|
        linkable_route("#{singular}_#{collection}",
                       "#{plural}/:id/#{collection}",
                       collection.to_s,
                       :conditions => { :method => :get })

        if Hobo.simple_has_many_association?(model.reflections[collection])
          linkable_route("new_#{singular}_#{collection.to_s.singularize}",
                         "#{plural}/:id/#{collection}/new",
                         "new_#{collection.to_s.singularize}",
                         :conditions => { :method => :get })
          linkable_route("create_#{singular}_#{collection.to_s.singularize}",
                         "#{plural}/:id/#{collection}",
                         "create_#{collection.to_s.singularize}",
                         :conditions => { :method => :post })

        end
      end
    end


    def web_method_routes
      controller.web_methods.each do |method|
        linkable_route("#{plural.singularize}_#{method}", "#{plural}/:id/#{method}", method.to_s, :conditions => { :method => :post })
      end
    end


    def index_action_routes
      controller.index_actions.each do |view|
        linkable_route("#{view}_#{plural}", "#{plural}/#{view}", view.to_s, :conditions => { :method => :get })
      end
    end


    def show_action_routes
      controller.show_actions.each do |view|
        linkable_route("#{plural.singularize}_#{view}", "#{plural}/:id/#{view}", view.to_s, :conditions => { :method => :get })
      end
    end


    def reorder_route
      linkable_route("reorder_#{plural}", "#{plural}/reorder", 'reorder', :conditions => { :method => :post })
    end
    
    
    def lifecycle_routes
      model::Lifecycle.creator_names.each do |creator|
        linkable_route("#{singular}_#{creator}",      "#{plural}/#{creator}", creator,           :conditions => { :method => :post }, :format => false)
        linkable_route("#{singular}_#{creator}_page", "#{plural}/#{creator}", "#{creator}_page", :conditions => { :method => :get },  :format => false)
      end
      model::Lifecycle.transition_names.each do |transition|
        linkable_route("#{singular}_#{transition}",      "#{plural}/:id/#{transition}", transition, 
                       :conditions => { :method => :put }, :format => false)
        linkable_route("#{singular}_#{transition}_page", "#{plural}/:id/#{transition}", "#{transition}_page", 
                       :conditions => { :method => :get }, :format => false)
      end
    end
        

    def user_routes
      prefix = plural == "users" ? "" : "#{singular}_"
      linkable_route("#{singular}_login",  "#{prefix}login",  'login')
      linkable_route("#{singular}_logout", "#{prefix}logout", 'logout')
      linkable_route("#{singular}_forgot_password", "#{prefix}forgot_password", 'forgot_password')
    end


    def named_route(name, route, options={})
      if controller.public_instance_methods.include?(options[:action].to_s)
        options.reverse_merge!(:controller => route_with_subsite(plural))
        name = name_with_subsite(name)
        route = route_with_subsite(route)
        map.named_route(name, route, options)
        format_route = options.delete(:format) != false
        map.named_route("formatted_#{name}", "#{route}.:format", options) if format_route
        true
      else
        false
      end
    end


    def linkable_route(name, route, action, options={})
      named_route(name, route, options.merge(:action => action.to_s)) and
        begin
          linkable_options = { :method => options[:conditions]._?[:method], :subsite => subsite }
          self.class.linkable!(model, action, linkable_options)
        end
    end


    def name_with_subsite(name)
      subsite ? "#{subsite}_#{name}" : name
    end


    def route_with_subsite(route)
      subsite ? "#{subsite}/#{route}" : route
    end

  end

end
