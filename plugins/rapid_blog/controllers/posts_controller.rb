bundle_model_controller :BlogPost do
  
  auto_actions :all, :except => :index

  include_taglib "post_pages", :bundle => _bundle_
  
  feature :comments do 
    include_taglib "rapid_comments", :bundle => _comments_bundle_
  end


  def index
    @posts_by_month = model.all_posts_by_month
    hobo_index
  end
  
end
