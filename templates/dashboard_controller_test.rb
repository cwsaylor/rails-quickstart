require "test_helper"
require "helpers/session_helper"

class Admin::DashboardControllerTest < ActionDispatch::IntegrationTest
  include SessionHelper

  test "should redirect index when not logged in" do
    get admin_root_url
    assert_response :redirect
  end

  test "should get index when logged in" do
    user = users(:alice)
    user_sign_in(user)
    get admin_root_url
    assert_response :success
  end
end
