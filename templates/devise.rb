puts '######################################################'
puts ' Setting up Devise'
puts '######################################################'

domain = ask("Domain name?")
email  = ask("Email from?")
user   = ask("Devise model, e.g. User?")

user_file_name    = user.underscore.singularize
user_factory_file = user.underscore.pluralize
user_model_name   = user.classify

gem 'devise'

run 'bundle install'

generate "devise:install"
generate :devise, user_model_name
generate "devise:views"

gsub_file 'config/initializers/devise.rb', 'please-change-me@config-initializers-devise.com', email

gsub_file 'config/environments/development.rb', '  config.action_mailer.raise_delivery_errors = false' do
  <<-RUBY
  config.action_mailer.default_url_options = { :host => 'localhost:3000' }
  # A dummy setup for development - no deliveries, but logged
  config.action_mailer.delivery_method = :smtp
  config.action_mailer.perform_deliveries = false
  config.action_mailer.raise_delivery_errors = true
  config.action_mailer.default :charset => "utf-8"
  RUBY
end

gsub_file 'config/environments/production.rb', '  config.i18n.fallbacks = true' do
  <<-RUBY
  config.i18n.fallbacks = true

  config.action_mailer.default_url_options = { :host => '#{domain}' }
  # Setup for production - deliveries, no errors raised
  config.action_mailer.delivery_method = :smtp
  config.action_mailer.perform_deliveries = true
  config.action_mailer.raise_delivery_errors = false
  config.action_mailer.default :charset => "utf-8"
  RUBY
end

if File.exists? 'test/factories'
  gsub_file "test/factories/#{user_factory_file}.rb", /^end$/ do
    <<-'RUBY'
    f.sequence(:email) {|n| "person#{n}@example.com" }
    f.password "testing"
    f.password_confirmation "testing"
  end
    RUBY
  end
end

append_file 'db/seeds.rb' do
  <<-FILE
puts 'SETTING UP DEFAULT USER LOGIN'
#{user_file_name} = #{user_model_name}.create! :email => 'user@domain.com', :password => 'change_me', :password_confirmation => 'change_me'
puts 'New user created: ' << #{user_file_name}.email
  FILE
end

puts '======================================================'
puts
puts ' Create a default user with rake db:seed'
puts
puts '======================================================'
