require File.dirname(__FILE__) + '/../test_helper'
require 'front_controller'

# Re-raise errors caught by the controller.
class FrontController; def rescue_action(e) raise e end; end

class FrontControllerTest < Test::Unit::TestCase
  def setup
    @controller = FrontController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  # Replace this with your real tests.
  def test_truth
    assert true
  end
end
