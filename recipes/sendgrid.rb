application(nil, env: "production") do
  <<-EOS

  # TODO Change default host
  config.action_mailer.default_url_options = { :host => 'herokuapp.com' }

  ActionMailer::Base.smtp_settings = {
    :address        => 'smtp.sendgrid.net',
    :port           => '587',
    :authentication => :plain,
    :user_name      => ENV['SENDGRID_USERNAME'],
    :password       => ENV['SENDGRID_PASSWORD'],
    :domain         => 'heroku.com',
    :enable_starttls_auto => true
  }
  ActionMailer::Base.delivery_method ||= :smtp

  EOS
end
