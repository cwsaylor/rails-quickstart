puts "Setting up Rspec & Cucumber..."

gem "cucumber-rails", :group => [:development, :test]
gem "rspec-rails", :group => [:development, :test]
gem "factory_girl_rails", :group => [:development, :test]
gem "webrat", :group => [:development, :test]
gem "database_cleaner", :group => [:development, :test]
gem "launchy", :group => [:development, :test]

run "bundle install"

generate "rspec:install"
generate "cucumber:install", "--force", "--rspec", "--webrat"

gsub_file "config/cucumber.yml", "default: <%= std_opts %> features" do
%{default: --format pretty features
old_default: <%= std_opts %> features}
end

run "rm -rf test/"

append_file ".gitignore", "webrat.log\n"

application "  config.generators.test_framework :rspec, :fixture_replacement => :factory_girl"

gsub_file "features/support/env.rb", ":rails", ":rack"

create_file "features/support/rack-test-default-host.rb" do <<-RUBY
Necessary evil thing: Rack::Test sports as default host
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
