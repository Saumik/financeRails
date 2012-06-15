require 'test_helper'

class PayeeControllerTest < ActionController::TestCase
  test "should get index" do
    get :budgets_index
    assert_response :success
  end

end
