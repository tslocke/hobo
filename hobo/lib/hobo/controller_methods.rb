 Hobo::ControllerMethods = classy_module do
  def self.hobo_user_controller(model=nil)
    @model = model
    include Hobo::ModelController
    include Hobo::UserController
  end

  def self.hobo_model_controller(model=nil)
    @model = model
    include Hobo::ModelController
  end

  def self.hobo_controller
    include Hobo::Controller
  end

  def home_page
    base_url
  end

end
