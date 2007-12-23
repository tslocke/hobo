require File.dirname(__FILE__) + '/../test_helper'
require 'forum_posts_controller'

# Re-raise errors caught by the controller.
class ForumPostsController; def rescue_action(e) raise e end; end

class ForumPostsControllerTest < Test::Unit::TestCase
  def setup
    @controller = ForumPostsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  # Replace this with your real tests.
  def test_truth
    assert true
  end
end
