pg_user = ask("PostgreSQL user name")
run 'cp config/database.yml config/database.yml.example'
gsub_file "config/database.yml", /username: .*$/, "username: #{pg_user}"
run 'rake db:create'

remove_file 'public/index.html'
remove_file 'app/views/layouts/application.html.erb'
remove_file 'app/assets/images/rails.png'
remove_file 'README'
create_file 'README.md'

gem 'slim-rails'
gem 'heroku'

if yes?('ActiveAdmin')
  gem 'activeadmin'
  gem "meta_search",    '>= 1.1.0.pre'
  active_admin = true
end

if yes?('Devise')
  gem 'devise'
  devise = true
end

inject_into_file 'Gemfile', :after => /gem 'uglifier'.*'\n/ do
<<eos
  gem 'compass-rails'
  gem 'zurb-foundation'
eos
end

gem_group :development do
  gem 'pry-rails'
end

gem_group :test do
  gem "factory_girl_rails"
  gem "capybara"
  gem "guard-rspec"
end

gem_group :test, :development do
  gem 'rspec-rails'
end

run "bundle install"

generate "foundation:install"
generate "foundation:layout"
generate "rspec:install"
generate "devise:install" if devise
generate "devise user" if devise
generate "devise:views" if devise
generate "active_admin:install" if active_admin

inject_into_file 'spec/spec_helper.rb', :after => "require 'rspec/autorun'\n" do
  "require 'capybara/rspec'\n"
end

inject_into_file 'spec/spec_helper.rb', :after => "RSpec.configure do |config|\n" do
  "  config.include FactoryGirl::Syntax::Methods\n\n"
end

inject_into_file 'config/environments/development.rb', :before => 'end' do
  "  config.action_mailer.default_url_options = { :host => 'localhost:3000' }"
end

inject_into_file 'config/environments/test.rb', :before => 'end' do
  "  config.action_mailer.default_url_options = { :host => 'localhost:3000' }"
end

inject_into_file 'config/environments/production.rb', :before => /^end/ do
<<eos
  # TODO Change default host
  config.action_mailer.default_url_options = { :host => 'changeme.com' }
eos
end

run 'bundle exec guard init rspec'
run 'rake db:migrate'

append_file '.gitignore' do
  '.DS_Store'
  'config/database.yml'
end

git :init
git :add => "."
git :commit => "-m 'Setup base Rails app.'"

