gem_group :test do
  gem "factory_girl_rails"
  gem "capybara"
  gem "guard-test"
  gem "database_cleaner"
end

inject_into_file 'test/test_helper.rb', :after => "require 'rails/test_help'\n" do
  <<-STRING
require 'capybara/rails'

DatabaseCleaner.strategy = :truncation

class ActionDispatch::IntegrationTest
  include Capybara::DSL
  self.use_transactional_fixtures = false
  teardown do
    DatabaseCleaner.clean
    Capybara.reset_sessions!
    Capybara.use_default_driver
  end
end
  STRING
end

run 'bundle exec guard init test'
