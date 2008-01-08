bundle_model_controller :Forum do

  auto_actions :all

  include_taglib 'rapid_forum', :bundle => _bundle_
  include_taglib 'forum_pages', :bundle => _bundle_

end
