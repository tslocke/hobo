ActionController::Base.class_eval do

  def self.hobo_user_controller
    include Hobo::ModelController
    include Hobo::UserController
  end

  def self.hobo_model_controller
    include Hobo::ModelController
  end

  def self.hobo_controller
    include Hobo::Controller
  end

  def home_page
    base_url
  end

end
