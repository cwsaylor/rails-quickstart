require "test_helper"

class PasswordsControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get new_password_url
    assert_response :success
  end

  test "should get edit" do
    user = users(:alice)

    get edit_password_url(token: user.password_reset_token)
    assert_response :success
  end

  test "should send password reset email" do
    user = users(:alice)

    assert_emails 1 do
      post passwords_url, params: {  email_address: user.email_address }
    end

    assert_redirected_to new_session_url
    assert_equal "Password reset instructions sent (if user with that email address exists).", flash[:notice]
  end

  test "should update password if passwords match" do
    user = users(:alice)

    patch password_url(token: user.password_reset_token), params: {  password: "passwords match", password_confirmation: "passwords match" }

    assert_redirected_to new_session_url
    assert_equal "Password has been reset.", flash[:notice]
  end

  test "should not update password if passwords do not match" do
    user = users(:alice)
    token = user.password_reset_token

    patch password_url(token: token), params: {  password: "passwords do not match", password_confirmation: "nope" }

    assert_redirected_to edit_password_url(token: token)
    assert_equal "Passwords did not match.", flash[:alert]
  end

  test "Should not expire password reset token within 3 hours" do
    travel -3.hours do
      user = users(:alice)
      @token = user.password_reset_token
    end

    get edit_password_url(token: @token)

    assert_response :success
  end

  test "Should expire password reset token after 4 hours" do
    travel -5.hours do
      user = users(:alice)
      @token = user.password_reset_token
    end

    get edit_password_url(token: @token)

    assert_redirected_to new_password_url
    assert_equal "Password reset link is invalid or has expired.", flash[:alert]
  end
end
