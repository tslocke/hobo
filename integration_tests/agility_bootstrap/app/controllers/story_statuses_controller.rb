class StoryStatusesController < ApplicationController

  hobo_model_controller

  auto_actions :write_only, :new, :index

  index_action :index2, :index3, :index4

  autocomplete

  def create
    hobo_create do
      if valid? && request.xhr?
        self.this = StoryStatus.all.paginate(:page => params[:page], :per_page => 20)
        hobo_ajax_response
      else
        create_response(:new)
      end
    end
  end

  def destroy
    hobo_destroy do
      if request.xhr?
        self.this = StoryStatus.all.paginate(:page => params[:page], :per_page => 20)
        hobo_ajax_response || render(:nothing => true)
      else
        destroy_response
      end
    end
  end

end
