require File.dirname(__FILE__) + '/../test_helper'
require 'forum_topics_controller'

# Re-raise errors caught by the controller.
class ForumTopicsController; def rescue_action(e) raise e end; end

class ForumTopicsControllerTest < Test::Unit::TestCase
  def setup
    @controller = ForumTopicsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  # Replace this with your real tests.
  def test_truth
    assert true
  end
end
