bundle_model_controller :BlogPost do
  
  auto_actions :all, :except => :collections

  include_taglib "post_pages", :bundle => _bundle_
  
  feature :comments do 
    include_taglib "hobo_comments", :bundle => _comments_bundle_
  end
        
end
