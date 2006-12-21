module Hobo

  module Controller

    include ControllerHelpers

    def self.included(base)
      if base.is_a?(Class)
        Hobo::ControllerHelpers.instance_methods.each {|m| base.hide_action(m)}
      end
    end


    protected

    def hobo_ajax_response(this)
      part_page = params[:part_page]
      r = params[:render]
      if r and part_page
        part_update_response(this, part_page, r.is_a?(Array) ? r : [r])
        true
      else
        false
      end
    end


    def part_update_response(this, part_page, part_updates)
      add_variables_to_assigns
      renderer = Hobo::Dryml.page_renderer(@template, [], part_page)

      render :update do |page|
        page << "var _update = typeof Hobo == 'undefined' ? Element.update : Hobo.updateElement;"
        for part_update in part_updates
          function = if part_update[:function]
                       part_update[:function][0..0].downcase + part_update[:function].camelize[1..-1]
                     else
                       "_update"
                     end

          obj = if part_update[:object] == "this" or !part_update[:object]
                  this
                else
                  Hobo.object_from_dom_id(part_update[:object])
                end

          if part_update[:as]
            part_html = render(:partial => (Hobo::ModelController.find_partial(obj.class, part_update[:as])),
                               :locals => { :this => obj })
            page.call(function, part_update[:id], part_html)

          elsif part_update[:part]
            dom_id = part_update[:id] || part_update[:part]
            part_html = renderer.call_part(dom_id, part_update[:part], obj)
            page.call(function, dom_id, part_html)

          else
            # part_update didn't specify any action :-/
          end
        end
        renderer.part_contexts.each_pair do |dom_id, p|
          part_id, model_id = p
          page.assign "hoboParts.#{dom_id}", [part_id, model_id]

          # not sure why this isn't happending automatically
          # but it's messing up ARTS, so chuck a newline in
          page << "\n"
        end
      end
    end


    def render_tag(tag, options={})
      add_variables_to_assigns
      render :text => Hobo::Dryml.render_tag(@template, tag, options)
    end


    def render_tags(objects, tag, options={})
      add_variables_to_assigns
      render(:locals => { :objects => objects, :tag => tag, :options => options },
             :inline => %{<% for o in objects %>
                            <%= Hobo::Dryml.render_tag(@template, tag, options.merge(:obj => o)) %>
                          <% end %>})
    end


    def site_search(query)
      res = Hobo.find_by_search(query)
      render_tags(res, "tag_for_object", :name => "search_result")
    end


    # Store the given user in the session.
    def current_user=(new_user)
      session[:user] = (new_user.nil? || new_user.is_a?(Symbol)) ? nil : new_user.id
      @current_user = new_user
    end


    def logged_in?
      current_user != Hobo.guest_user
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

    # Filter method to enforce a login requirement.
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
    def login_required
      username, passwd = get_auth_data
      self.current_user ||= Hobo.user_model.authenticate(username, passwd) || :false if username && passwd
      logged_in? && authorized? ? true : access_denied
    end

    # Redirect as appropriate when an access request fails.
    #
    # The default action is to redirect to the login screen.
    #
    # Override this method in your controllers if you want to have special
    # behavior in case the user is not authorized
    # to access the requested action.  For example, a popup window might
    # simply close itself.
    def access_denied
      respond_to do |accepts|
        accepts.html do
          store_location
          redirect_to login_url
        end
        accepts.xml do
          headers["Status"]           = "Unauthorized"
          headers["WWW-Authenticate"] = %(Basic realm="Web Password")
          render :text => "Could't authenticate you", :status => '401 Unauthorized'
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
      session[:return_to] ? redirect_to_url(session[:return_to]) : redirect_to(default)
      session[:return_to] = nil
    end

    # When called with before_filter :login_from_cookie will check for an :auth_token
    # cookie and log the user back in if apropriate
    def login_from_cookie
      return unless cookies[:auth_token] && !logged_in?
      user = Hobo.user_model.find_by_remember_token(cookies[:auth_token])
      if user && user.remember_token?
        user.remember_me
        self.current_user = user
        cookies[:auth_token] = { :value => self.current_user.remember_token ,
                                 :expires => self.current_user.remember_token_expires_at }
        flash[:notice] = "Logged in successfully"
      end
    end

    private
    @@http_auth_headers = %w(X-HTTP_AUTHORIZATION HTTP_AUTHORIZATION Authorization)
    # gets BASIC auth info
    def get_auth_data
      auth_key  = @@http_auth_headers.detect { |h| request.env.has_key?(h) }
      auth_data = request.env[auth_key].to_s.split unless auth_key.blank?
      return auth_data && auth_data[0] == 'Basic' ? Base64.decode64(auth_data[1]).split(':')[0..1] : [nil, nil]
    end

  end
end
