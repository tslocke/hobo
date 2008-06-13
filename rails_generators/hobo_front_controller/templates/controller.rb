class <%= class_name %>Controller < ApplicationController

  hobo_controller

  def index; end

  def search
    if params[:query]
      site_search(params[:query])
    end
  end

end
