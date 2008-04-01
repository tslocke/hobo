class StoryStatusesController < ApplicationController

  hobo_model_controller

  auto_actions :write_only, :index

end
