class ForumsController < ApplicationController

  hobo_model_controller

  auto_actions :all

  include_taglib 'taglibs/forum'

end
