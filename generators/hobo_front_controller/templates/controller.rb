class <%= class_name %>Controller < ApplicationController

  hobo_controller
  
  def index; end

  def search
    if request.post?
      site_search(params[:query])
    end
  end

end
