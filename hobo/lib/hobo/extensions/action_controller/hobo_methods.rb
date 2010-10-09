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

end
