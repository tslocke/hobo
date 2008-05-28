class <%= controller_class_name %>Controller < ApplicationController

  hobo_model_controller

  # changes require server restart
  auto_actions :all

end
