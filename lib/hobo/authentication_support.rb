module Hobo

  module AuthenticationSupport

    # Filter method to enforce a login requirement.
    def logged_in?
      not current_user.guest?
    end


    # Check if the user is authorized.
    #
    # Override this method in your controllers if you want to restrict access
    # to only a few actions or if you want to check if the user
    # has the correct rights.
    #
    # Example:
    #
    #  # only allow nonbobs
    #  def authorize?
    #    current_user.login != "bob"
    #  end
    def authorized?
      true
    end

    #
    # To require logins for all actions, use this in your controllers:
    #
    #   before_filter :login_required
    #
    # To require logins for specific actions, use this in your controllers:
    #
    #   before_filter :login_required, :only => [ :edit, :update ]
    #
    # To skip this in a subclassed controller:
    #
    #   skip_before_filter :login_required
    #
    def login_required(user_model=nil)
      auth_model = user_model || User.default_user_model
      if current_user.guest?
        username, passwd = get_auth_data
        self.current_user = auth_model.authenticate(username, passwd) || nil if username && passwd && auth_model
      end
      if logged_in? && authorized? && (user_model.nil? || current_user.is_a?(user_model))
        true
      else
        access_denied(auth_model)
      end
    end

    # Redirect as appropriate when an access request fails.
    #
    # The default action is to redirect to the login screen.
    #
    # Override this method in your controllers if you want to have special
    # behavior in case the user is not authorized
    # to access the requested action.  For example, a popup window might
    # simply close itself.
    def access_denied(user_model)
      respond_to do |accepts|
        accepts.html do
          store_location
          redirect_to(login_url(user_model))
        end
        accepts.xml do
          headers["Status"]           = "Unauthorized"
          headers["WWW-Authenticate"] = %(Basic realm="Web Password")
          render :text => ht("hobo.messages.unauthenticated", :default=>["Couldn't authenticate you"], :status => '401 Unauthorized')
        end
      end
      false
    end

    # Store the URI of the current request in the session.
    #
    # We can return to this location by calling #redirect_back_or_default.
    def store_location
      session[:return_to] = request.request_uri
    end

    # Redirect to the URI stored by the most recent store_location call or
    # to the passed default.
    def redirect_back_or_default(default)
      session[:return_to] ? redirect_to(session[:return_to]) : redirect_to(default)
      session[:return_to] = nil
    end

    # When called with before_filter :login_from_cookie will check for an :auth_token
    # cookie and log the user back in if apropriate
    def login_from_cookie
      if (user = authenticated_user_from_cookie)
        user.remember_me
        self.current_user = user
        create_auth_cookie
      end
    end
    
    
    def authenticated_user_from_cookie
      !logged_in? and
          cookie = cookies[:auth_token] and
          (token, model_name = cookie.split) and
          user_model = model_name._?.safe_constantize and
          user = user_model.find_by_remember_token(token) and
          user.remember_token? and
          user
    end

    def create_auth_cookie
      cookies[:auth_token] = { :value => "#{current_user.remember_token} #{current_user.class.name}",
                               :expires => current_user.remember_token_expires_at }
    end

    private
    @@http_auth_headers = %w(X-HTTP_AUTHORIZATION HTTP_AUTHORIZATION Authorization)
    # gets BASIC auth info
    def get_auth_data
      auth_key  = @@http_auth_headers.detect { |h| request.env.has_key?(h) }
      auth_data = request.env[auth_key].to_s.split unless auth_key.blank?
      username, pw = if auth_data && auth_data[0] == 'Basic'
                       Base64.decode64(auth_data[1]).split(':')[0..1]
                     else
                       [nil, nil]
                     end
    end

  end

end
