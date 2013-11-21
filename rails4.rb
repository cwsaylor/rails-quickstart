gsub_file "config/database.yml", /username: .*$/, "username: <%= $USER %>"

inject_into_file "config/database.yml", :before => "  adapter: postgresql" do
  "  min_messages: WARNING\n"
end

remove_file 'app/views/layouts/application.html.erb'

create_file 'Procfile' do
  "web: bundle exec thin start -p $PORT"
end

create_file 'env.example' do
  <<-EOS
#AWS_BUCKET=
#AWS_ACCESS_KEY_ID=
#AWS_SECRET_ACCESS_KEY=
  EOS
end

create_file '.slugignore' do
  <<-EOS
/spec
/doc
  EOS
end

gem_group :development do
  gem 'pry-rails'
  gem 'rb-fsevent'
end

gem_group :test do
  gem 'capybara'
  gem 'factory_girl_rails'
  gem 'guard-rspec'
end

gem_group :test, :development do
  gem 'debugger'
  gem 'rspec-rails'
end

gsub_file "Gemfile", "# gem 'therubyracer', platforms: :ruby", "gem 'therubyracer', platforms: :ruby"

gem 'compass'
gem 'foreman'
gem 'libv8'
gem 'simple_form'
gem 'slim-rails'
gem 'thin'
gem 'zurb-foundation'

if yes?('ActiveAdmin')
  gem 'activeadmin', github: 'gregbell/active_admin'
  active_admin = true
end

if yes?('Devise')
  gem 'devise'
  devise = true
end

if yes?('Delayed Job')
  gem 'delayed_job_active_record'
  gem 'hirefire-resource'

  append_file "Procfile" do
    "\nworker: bundle exec rake jobs:work"
  end

  create_file "config/initializers/hirefire.rb" do
    <<-EOS
HireFire::Resource.configure do |config|
  config.dyno(:worker) do
    HireFire::Macro::Delayed::Job.queue
  end
end
    EOS
  end
  dj = true
end

inject_into_file "Gemfile", :after => "source 'https://rubygems.org'\n" do
  "ruby '2.0.0'\n"
end

run "bundle install"
run "rake db:create"

generate "rspec:install"
generate "foundation:install"
generate "foundation:layout application --slim"
generate "simple_form:install --foundation"
generate "active_admin:install"      if active_admin
generate "devise:install"            if devise
generate "devise user"               if devise
generate "devise:views"              if devise
generate "delayed_job:active_record" if dj

inject_into_file 'spec/spec_helper.rb', :after => "require 'rspec/autorun'\n" do
  "require 'capybara/rspec'\n"
end

inject_into_file 'spec/spec_helper.rb', :after => "RSpec.configure do |config|\n" do
  "  config.include FactoryGirl::Syntax::Methods\n\n"
end

inject_into_file 'config/application.rb', :after => "# config.i18n.default_locale = :de\n" do
  "\n    config.autoload_paths += %W(\#{config.root}/lib)\n"
end

if active_admin
  inject_into_file 'config/application.rb', :after => "# config.i18n.default_locale = :de\n" do
    "\n    config.assets.precompile += %w[active_admin.css active_admin.js active_admin/print.css]\n"
  end
end

inject_into_file 'config/application.rb', :after => "# config.i18n.default_locale = :de\n" do
  "\n    config.assets.initialize_on_precompile = false\n"
end

inject_into_file 'config/environments/development.rb', :before => /^end$/ do
  "\n  config.action_mailer.default_url_options = { :host => 'localhost:3000' }\n"
end

inject_into_file 'config/environments/test.rb', :before => /^end$/ do
  "\n  config.action_mailer.default_url_options = { :host => 'localhost:3000' }\n"
end

inject_into_file 'config/environments/production.rb', :before => /^end$/ do
  <<-EOS

  # TODO Change default host
  config.action_mailer.default_url_options = { :host => 'changeme.com' }

  ActionMailer::Base.smtp_settings = {
    :address        => 'smtp.sendgrid.net',
    :port           => '587',
    :authentication => :plain,
    :user_name      => ENV['SENDGRID_USERNAME'],
    :password       => ENV['SENDGRID_PASSWORD'],
    :domain         => 'changeme.com'
  }
  ActionMailer::Base.delivery_method ||= :smtp
  EOS
end

run 'bundle exec guard init rspec'

gsub_file "Guardfile", "guard 'rspec' do", 'guard "rspec", :all_after_pass => false, :all_on_start => false, :cli => "--color --format nested --drb" do'

if devise
  create_file "spec/support/devise.rb" do
    <<-EOS
RSpec.configure do |config|
  config.include Devise::TestHelpers, :type => :controller
end
    EOS
  end

  migration_file = Dir['db/migrate/*_devise_create_users.rb'].first
  puts migration_file
  gsub_file migration_file, "# t.string",   "t.string"
  gsub_file migration_file, "# t.datetime", "t.datetime"
  gsub_file migration_file, "# t.integer",  "t.integer"
  gsub_file migration_file, "# add_index",  "add_index"
  gsub_file "app/models/user.rb", "validatable",   "validatable, :confirmable"
end

run 'rake db:migrate'

append_file '.gitignore' do
  <<-EOS
.DS_Store
config/database.yml
.env
  EOS
end

generate "controller pages index --no-helper --no-assets"

inject_into_file 'config/routes.rb', :after => "routes.draw do\n" do
  "  root :to => 'pages#index'\n"
end

run "curl https://gist.github.com/rwdaigle/2253296/raw/newrelic.yml > config/newrelic.yml"

git :init
git :add => "."
git :commit => "-m 'Setup base Rails app for Heroku with #{'ActiveAdmin, ' if active_admin}#{'Delayed Job, ' if dj}Capybara, #{'Devise, ' if devise}FactoryGirl, Foreman, Guard, New Relic, Rspec, Sendgrid, Slim, Thin, Zurb Foundation.'"

puts "######################################"
puts "heroku create"
puts "git push heroku master"
puts "heroku addons:add sendgrid:starter"
puts "heroku addons:add newrelic:standard"
puts "heroku config:set NEW_RELIC_APP_NAME=foo"
puts "heroku run rake db:migrate"
puts "heroku restart"
puts "heroku addons:open sendgrid"
puts "heroku addons:open newrelic"
puts "heroku ps:scale worker=1" if dj
puts "######################################"

