puts "Setting up Rspec..."

gem "rspec-rails",        :group => [:development, :test]
gem "factory_girl_rails", :group => [:development, :test]

run "bundle install"

generate "rspec:install"

run "rm -rf test/"

application "  config.generators.test_framework :rspec, :fixture_replacement => :factory_girl"

@rspec = true
