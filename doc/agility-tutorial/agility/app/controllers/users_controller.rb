class UsersController < ApplicationController

  hobo_user_controller

  auto_actions :all, :except => [ :index, :create ]

end
