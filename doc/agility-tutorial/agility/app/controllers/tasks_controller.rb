class TasksController < ApplicationController

  hobo_model_controller

  auto_actions :write_only, :new, :edit

end
