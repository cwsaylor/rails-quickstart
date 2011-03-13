puts "Setting up Cucumber..."

if yes?("Use capybara? (Answering no will setup webrat.)")
  framework = "capybara"
else
  framework = "webrat"
end

gem "cucumber-rails",   :group => [:development, :test]
gem "database_cleaner", :group => [:development, :test]
gem "launchy",          :group => [:development, :test]
gem "#{framework}",     :group => [:development, :test]

run "bundle install"

if @rspec
  generate "cucumber:install", "--force", "--rspec", "--#{framework}"
else
  generate "cucumber:install", "--force", "--#{framework}"
end

gsub_file "config/cucumber.yml", "default: <%= std_opts %> features" do
%{default: --format pretty features
old_default: <%= std_opts %> features}
end

if framework == "webrat"
  append_file ".gitignore" do
    "webrat.log"
  end

  gsub_file "features/support/env.rb", ":rails", ":rack"

  create_file "features/support/rack-test-default-host.rb" do <<-RUBY
# Necessary evil thing: Rack::Test sports as default host
# "example.org", but Webrat and Ruby on Rails's integration test
# classes use "example.com"; this discrepancy leads to Webrat not
# being able to follow simple internal redirects.
#
# Drop in in features/support/
module Rack
  module Test
    DEFAULT_HOST = "example.com"
  end
end
  RUBY
  end
end
