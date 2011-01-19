gem "cucumber", :group => [:development, :test]
gem "cucumber-rails", :group => [:development, :test]
gem "rspec", :group => [:development, :test]
gem "rspec-rails", :group => [:development, :test]
gem "webrat"

run "bundle install"

generate "rspec:install"
generate "cucumber:install", "--force", "--rspec", "--webrat"

run "rm -rf test/"

application "  config.generators.test_framework :rspec, :fixture_replacement => :factory_girl"
