module SessionHelper
  SIGNED_COOKIE_SALT = "signed cookie"

  def user_sign_in(user)
    cookies[:session_id] = Rails.application.message_verifier(SIGNED_COOKIE_SALT).generate(user.sessions.create.id)
  end
end
