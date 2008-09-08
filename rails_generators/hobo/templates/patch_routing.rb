if Rails::VERSION::STRING.in? ["2.1.0", "2.1.1"]
  module ActionController
    module Routing
      class RouteSet
        def clear_recognize_optimized!
          instance_eval %{
            def recognize_optimized(path, env)
              write_recognize_optimized
              recognize_optimized(path, env)            
            end
          }, __FILE__, __LINE__
        end
      
        def clear_with_optimization!
          clear_without_optimization!
          clear_recognize_optimized!
        end
        alias_method_chain :clear!, :optimization

      end
    end
  end

  ActionController::Routing::Routes.reload!

else
  RAILS_DEFAULT_LOGGER.info "****"
  RAILS_DEFAULT_LOGGER.info "**** The file config/initializers/patch_routing.rb is not in use"
  RAILS_DEFAULT_LOGGER.info "**** with this version of Rails and can be removed"
  RAILS_DEFAULT_LOGGER.info "****"
end
  
