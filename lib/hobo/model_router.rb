module Hobo
  
  class ModelRouter
    
    APP_ROOT = "#{RAILS_ROOT}/app"
    
    class << self
      
      def add_routes(map)
        begin 
          ActiveRecord::Base.connection.reconnect! unless ActiveRecord::Base.connection.active?
        rescue
          # No database, no routes
          return
        end

        require "#{APP_ROOT}/controllers/application" unless Object.const_defined? :ApplicationController
        require "#{APP_ROOT}/assemble.rb" if File.exists? "#{APP_ROOT}/assemble.rb"
        
        add_routes_for(map, nil)

        # Any directory inside app/controllers defines a subsite
        subsites = Dir["#{APP_ROOT}/controllers/*"].map { |f| File.basename(f) if File.directory?(f) }.compact
        subsites.each { |subsite| add_routes_for(map, subsite) }
      end
      
      
      def add_routes_for(map, subsite)
        module_name = subsite._?.camelize
        Hobo.models.each do |model|
          controller_name = "#{model.name.pluralize}Controller"
          is_defined = if subsite 
                         Object.const_defined?(module_name) && module_name.constantize.const_defined?(controller_name)
                       else
                         Object.const_defined?(controller_name)
                       end
          controller_filename = File.join(*["#{APP_ROOT}/controllers", subsite, "#{controller_name.underscore}.rb"].compact) 
          if is_defined || File.exists?(controller_filename)
            owner_module = subsite ? module_name.constantize : Object
            controller = owner_module.const_get(controller_name)
            ModelRouter.new(map, model, controller, subsite)
          end
        end
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
        resource_routes
        collection_routes
        web_method_routes
        show_action_routes
        user_routes if controller < Hobo::UserController
      end
    end
    
    
    def resource_routes
      # We re-implement resource routing - routes are not created for
      # actions that the controller does not provide
      named_route(plural,                plural,               :action => "index",   :conditions => { :method => :get })

      named_route("new_#{singular}",     "#{plural}/new",      :action => "new",     :conditions => { :method => :get })
      named_route("edit_#{singular}",    "#{plural}/:id/edit", :action => "edit",    :conditions => { :method => :get })
      named_route(singular,              "#{plural}/:id",      :action => "show",    :conditions => { :method => :get })

      named_route("create_#{singular}",  plural,               :action => "create",  :conditions => { :method => :post })
      named_route("update_#{singular}",  "#{plural}/:id",      :action => "update",  :conditions => { :method => :put })
      named_route("destroy_#{singular}", "#{plural}/:id",      :action => "destroy", :conditions => { :method => :delete })
    end
    
    
    def collection_routes
      controller.collections.each do |collection|
        new_method = Hobo.simple_has_many_association?(model.reflections[collection])
        named_route("#{singular}_#{collection}",
                    "#{plural}/:id/#{collection}",
                    :action => "show_#{collection}",
                    :conditions => { :method => :get })

        named_route("new_#{singular}_#{collection.to_s.singularize}",
                    "#{plural}/:id/#{collection}/new",
                    :action => "new_#{collection.to_s.singularize}",
                    :conditions => { :method => :get }) if new_method
      end
    end
    
    
    def web_method_routes
      controller.web_methods.each do |method|
        named_route("#{plural.singularize}_#{method}", "#{plural}/:id/#{method}",
                    :action => method.to_s, :conditions => { :method => :post })
      end
    end
    
    
    def index_action_routes
      controller.index_actions.each do |view|
        named_route("#{view}_#{plural}", "#{plural}/#{view}",
                    :action => view.to_s, :conditions => { :method => :get })
      end
    end

    
    def show_action_routes
      controller.show_actions.each do |view|
        named_route("#{plural.singularize}_#{view}", "#{plural}/:id/#{view}",
                    :action => view.to_s, :conditions => { :method => :get })
      end
    end
    
        
    def user_routes
      prefix = plural == "users" ? "" : "#{singular}_"
      named_route("#{singular}_login",  "#{prefix}login",  :action => 'login')
      named_route("#{singular}_logout", "#{prefix}logout", :action => 'logout')
      named_route("#{singular}_signup", "#{prefix}signup", :action => 'signup')
    end
    
    
    def named_route(name, route, options={})
      if controller.public_instance_methods.include?(options[:action].to_s)
        options.reverse_merge!(:controller => route_with_subsite(plural))
        map.named_route(name_with_subsite(name), route_with_subsite(route), options)
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
