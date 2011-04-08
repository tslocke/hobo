ActionController::Base.class_eval do

  def self.hobo_user_controller
    include Hobo::Controller::Model
    include Hobo::Controller::User
  end

  def self.hobo_model_controller
    include Hobo::Controller::Model
  end

  def self.hobo_controller
    include Hobo::Controller
  end

  def home_page
    base_url
  end

  # moved here from authentication_support.rb for easy overriding
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
        render :text => t("hobo.messages.unauthenticated", :default=>["Couldn't authenticate you"]), :status => '401 Unauthorized'
      end
    end
    false
  end

end
