require "test_helper"
require "helpers/session_helper"

class SessionsControllerTest < ActionDispatch::IntegrationTest
  include SessionHelper

  test "should get new" do
    get new_session_url
    assert_response :success
  end

  test "should create user session with valid login" do
    user = users(:alice)

    assert_difference("Session.count") do
      post session_url, params: {  email_address: user.email_address, password: "password" }
    end

    assert_redirected_to root_url
    assert_not_empty cookies[:session_id]
  end

  test "should redirect user session with invalid login" do
    user = users(:alice)

    assert_no_difference("Session.count") do
      post session_url, params: {  email_address: user.email_address, password: "incorrect password" }
    end

    assert_redirected_to new_session_url
    assert_equal "Try another email address or password.", flash[:alert]
  end

  # Not sure how to test rate limiting yet
  # test "should rate limit create user session" do
  #   user = users(:alice)
  #
  #   10.times do
  #     post session_url, params: {  email_address: user.email_address, password: "incorrect password" }
  #     assert_equal "Try another email address or password.", flash[:alert]
  #   end
  #
  #   post session_url, params: {  email_address: user.email_address, password: "incorrect password" }
  #   assert_redirected_to new_session_url
  #   assert_equal "Try again later.", flash[:alert]
  # end

  test "should destroy user session" do
    user = users(:alice)
    user_sign_in(user)
    assert_not_nil cookies[:session_id]

    delete session_url
    assert_redirected_to new_session_url
    assert_empty cookies[:session_id]
  end
end
