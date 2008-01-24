bundle_model_controller :Images do
  
  include_taglib "image_pages", :bundle => _bundle_

  def update
    hobo_update do
      redirect_to(:action => :index) if valid?
    end
  end

  def index
    hobo_index model.fullsize_images
  end

  index_action :select_image do
    index
  end
  
end
