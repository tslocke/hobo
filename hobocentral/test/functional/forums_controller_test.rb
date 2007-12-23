require File.dirname(__FILE__) + '/../test_helper'
require 'forums_controller'

# Re-raise errors caught by the controller.
class ForumsController; def rescue_action(e) raise e end; end

class ForumsControllerTest < Test::Unit::TestCase
  def setup
    @controller = ForumsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  # Replace this with your real tests.
  def test_truth
    assert true
  end
end
