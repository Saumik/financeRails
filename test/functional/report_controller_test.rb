require 'test_helper'

class ReportControllerTest < ActionController::TestCase
  test "should get month_expenses" do
    get :month_expenses
    assert_response :success
  end

end
