bundle_model_controller :ForumTopic do

  auto_actions :all, :except => :index

  include_taglib "forum_topic_pages", :bundle => _bundle_
  
  track_viewings :show

end
