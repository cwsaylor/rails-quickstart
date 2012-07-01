run 'cp config/database.yml config/database.yml.example'
remove_file 'public/index.html'
remove_file 'public/images/rails.png'
remove_file 'app/views/layouts/application.html.erb'
run 'echo "" > README'

gem 'haml-rails'
gem 'pry-rails', :group => :development
gem 'rspec-rails', :group => [:test, :development]

gem_group :test do
  gem "factory_girl_rails"
  gem "capybara"
  gem "guard-rspec"
end

run "bundle install"

generate "rspec:install"

inject_into_file 'spec/spec_helper.rb', :after => "require 'rspec/autorun'\n" do
  "require 'capybara/rspec'\n"
end

inject_into_file 'spec/spec_helper.rb', :after => "RSpec.configure do |config|\n" do
  "  config.include FactoryGirl::Syntax::Methods\n\n"
end

run 'bundle exec guard init rspec'

append_file '.gitignore' do
  '.DS_Store'
  'config/database.yml'
end

git :init
git :add => "."
git :commit => "-m 'Setup base Rails app with Haml, Rspec, Factory Girl, Capybara, Guard and Pry.'"

