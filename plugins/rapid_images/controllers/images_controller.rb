bundle_model_controller :Image do
  
  include_taglib "image_pages", :bundle => _bundle_
  
  auto_actions :create

  def update
    hobo_update do
      redirect_to(:action => :index) if valid?
    end
  end

  def index
    hobo_index model.fullsize
  end

  index_action :select_image do
    index
  end
  
end
