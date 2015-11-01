# Preview all emails at http://localhost:3000/rails/mailers/foo
class DeviseMailerPreview < ActionMailer::Preview
  def confirmation_instructions
    user = FactoryGirl.create(:user)
    Devise::Mailer.confirmation_instructions(user, "12345678")
  end

  def reset_password_instructions
    user = FactoryGirl.create(:user)
    Devise::Mailer.reset_password_instructions(user, "12345678")
  end

  def unlock_instructions
    user = FactoryGirl.create(:user)
    Devise::Mailer.unlock_instructions(user, "12345678")
  end
end
