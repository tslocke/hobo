# Routing from specific domain or host

Originally written by Fernando on 2010-04-09.

If you need, like me, routing something using specific domain or host, just create a file under <pre>yourapp/config/initializers</pre> a file like this:

    module ActionController
    
      module Routing
    
        class RouteSet
          def extract_request_environment(request)
            env = { :method => request.method }
            env[:domain] = request.domain if request.domain
            env[:host] = request.host if request.host          
            env
          end
        end
    
        class Route
          alias_method :old_recognition_conditions, :recognition_conditions
          def recognition_conditions
            result = old_recognition_conditions
            result << "conditions[:domain] === env[:domain]" if conditions[:domain]
            result << "conditions[:host] === env[:host]" if conditions[:host]        
            result
          end
        end
    
      end
    
    end


Now, you're be able to use this in your routes:

`map.connect '', :controller => 'admin/front', :action => 'index', :conditions=>{ :domain=>'admin.yourdomain.com' }`



