if defined? ActionController::Routing::RouteSet

  class ActionController::Routing::RouteSet
    # Monkey patch this method so routes are reloaded on *every*
    # request. Without this Rails checks the mtime of config/routes.rb
    # which doesn't take into account Hobo's auto routing

    def reload_with_hobo_routes
      if Hobo::ModelRouter.reload_routes_on_every_request
        load!
      else
        reload_without_hobo_routes
      end
    end
    alias_method_chain :reload, :hobo_routes

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

    class << self

      attr_accessor :reload_routes_on_every_request

      def reset_linkables
        @linkable = Set.new
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
      
      def called_from_generator?
        caller[-1] =~ /script[\/\\]generate:\d+$/ || caller[-1] =~ /script[\/\\]destroy:\d+$/
      end

      def add_routes(map)
        # Don't create routes if it's a generator that's running
        return if called_from_generator?

        reset_linkables

        begin
          ActiveRecord::Base.connection.reconnect! unless ActiveRecord::Base.connection.active?
        rescue
          # No database, no routes
          return
        end

        require "#{RAILS_ROOT}/app/controllers/application" unless Object.const_defined? :ApplicationController

        # Add non-subsite, and all subsite routes
        [nil, *Hobo.subsites].each { |subsite| add_routes_for(map, subsite) }

        add_developer_routes(map) if Hobo.developer_features?

        # Run the DRYML generators
        # TODO: This needs a proper home 
        Hobo::Dryml::DrymlGenerator.run unless caller[-1] =~ /[\/\\]rake:\d+$/
      rescue ActiveRecord::StatementInvalid => e
        # Database problem? Just continue without routes
        ActiveRecord::Base.logger.warn "!! Database exception during Hobo routing -- continuing without routes"
        ActiveRecord::Base.logger.warn "!! #{e.to_s}"
      end


      def add_routes_for(map, subsite)
        Hobo::ModelController.all_controllers(subsite, :force).each { |controller| ModelRouter.new(map, controller, subsite) }
      end


      def add_developer_routes(map)
        map.dryml_support "dryml/:action", :controller => "hobo/dryml/dryml_support"
        map.dev_support   "dev/:action",   :controller => "hobo/dev"
      end

    end

    # specify that an id CANNOT be null - needed to disambiguate /models from /models/[nil] - see #251
    ID_REQUIREMENT = { :id => /[^#{ActionController::Routing::SEPARATORS.join}]+/ }

    def initialize(map, controller, subsite)
      @map = map
      @controller = controller
      @subsite = subsite
      add_routes
    end


    attr_reader :map, :model, :controller, :subsite
    
    
    def model
      controller.model
    end


    def plural
      model.name.underscore.pluralize
    end


    def singular
      model.name.underscore
    end


    def add_routes
      # Simple support for composite models, we might later need a CompositeModelController
      if model < Hobo::CompositeModel
        map.connect "#{plural}/:id", :controller => plural, :action => 'show', :requirements => ID_REQUIREMENT

      elsif controller < Hobo::ModelController
        # index routes need to be first so the index names don't get
        # taken as IDs
        index_action_routes
        lifecycle_routes if defined? model::Lifecycle
        resource_routes
        owner_routes
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

      linkable_route(singular, "#{plural}/:id", :show, :conditions => { :method => :get }, :requirements => ID_REQUIREMENT)

      linkable_route("create_#{singular}",  plural,          :create,  :conditions => { :method => :post })
      linkable_route("update_#{singular}",  "#{plural}/:id", :update,  :conditions => { :method => :put }, :requirements => ID_REQUIREMENT)
      linkable_route("destroy_#{singular}", "#{plural}/:id", :destroy, :conditions => { :method => :delete }, :requirements => ID_REQUIREMENT)
    end


    def owner_routes
      controller.owner_actions.each_pair do |owner, actions|
        collection_refl = model.reverse_reflection(owner)
        raise HoboError, "Hob routing error -- can't find reverse association for #{model}##{owner} " +
                         "(e.g. the :has_many that corresponds to a :belongs_to)" if collection_refl.nil?
        collection         = collection_refl.name
        owner_class        = model.reflections[owner].klass.name.underscore

        owner = owner.to_s.singularize if model.reflections[owner].macro == :has_many

        collection_path = "#{owner_class.pluralize}/:#{owner_class}_id/#{collection}"

        actions.each do |action|
          case action
          when :index
            linkable_route("#{plural}_for_#{owner}",          collection_path,          "index_for_#{owner}",
                           :conditions => { :method => :get })
          when :new
            linkable_route("new_#{singular}_for_#{owner}",    "#{collection_path}/new", "new_for_#{owner}",
                           :conditions => { :method => :get })
          when :create
            linkable_route("create_#{singular}_for_#{owner}", collection_path,          "create_for_#{owner}",
                           :conditions => { :method => :post })
          end
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
      model::Lifecycle.creators.values.where.publishable?.*.name.each do |creator|
        linkable_route("do_#{singular}_#{creator}", "#{plural}/#{creator}", "do_#{creator}",
                       :conditions => { :method => :post }, :format => false, :linkable_action => creator)
        linkable_route("#{singular}_#{creator}",    "#{plural}/#{creator}", creator,  :conditions => { :method => :get },  :format => false)
      end
      model::Lifecycle.transitions.where.publishable?.*.name.each do |transition|
        linkable_route("do_#{singular}_#{transition}", "#{plural}/:id/#{transition}", "do_#{transition}",
                       :conditions => { :method => :put }, :format => false, :linkable_action => transition)
        linkable_route("#{singular}_#{transition}", "#{plural}/:id/#{transition}", transition,
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
        format_route = options.delete(:format) != false
        map.named_route(name, route, options)
        map.named_route("formatted_#{name}", "#{route}.:format", options) if format_route
        true
      else
        false
      end
    end


    def linkable_route(name, route, action, options={})
      linkable_action = options.delete(:linkable_action) || action
      named_route(name, route, options.merge(:action => action.to_s)) and
        begin
          linkable_options = { :method => options[:conditions]._?[:method], :subsite => subsite }
          self.class.linkable!(model, linkable_action, linkable_options)
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
