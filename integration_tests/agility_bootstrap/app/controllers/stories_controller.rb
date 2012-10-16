class StoriesController < ApplicationController

  hobo_model_controller

  auto_actions :all, :except => :index

  auto_actions_for :project, [:new, :create]

end
