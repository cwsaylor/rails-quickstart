pg_user = ask("PostgreSQL user name")
run 'cp config/database.yml config/database.yml.example'
gsub_file "config/database.yml", /username: .*$/, "username: #{pg_user}"

remove_file 'public/index.html'
remove_file 'app/views/layouts/application.html.erb'
remove_file 'app/assets/images/rails.png'
remove_file 'README'
create_file 'README.md'

gem 'slim-rails'
gem 'simple_form'
gem 'newrelic_rpm'

if yes?('ActiveAdmin')
  gem 'activeadmin'
  active_admin = true
end

if yes?('Devise')
  gem 'devise'
  devise = true
end

inject_into_file 'Gemfile', :after => /gem 'uglifier'.*'\n/ do
<<eos
  gem 'therubyracer'
  gem 'less-rails'
  gem 'twitter-bootstrap-rails', :git => 'git://github.com/seyhunak/twitter-bootstrap-rails.git'
eos
end

gem_group :development do
  gem 'pry-rails'
  gem 'debugger'
  gem 'rb-fsevent', '~> 0.9'
end

gem_group :test do
  gem 'factory_girl_rails'
  gem 'capybara'
  gem 'guard-rspec'
end

gem_group :test, :development do
  gem 'rspec-rails'
end

run "bundle install"
run 'rake db:create'

generate "bootstrap:install less"
generate "bootstrap:layout application fixed"
generate "rspec:install"
generate "devise:install" if devise
generate "devise user" if devise
generate "devise:views" if devise
generate "active_admin:install" if active_admin
generate "simple_form:install --bootstrap"

inject_into_file 'spec/spec_helper.rb', :after => "require 'rspec/autorun'\n" do
  "require 'capybara/rspec'\n"
end

inject_into_file 'spec/spec_helper.rb', :after => "RSpec.configure do |config|\n" do
  "  config.include FactoryGirl::Syntax::Methods\n\n"
end

inject_into_file 'config/application.rb', :after => "config.assets.version = '1.0'\n" do
<<eos
    config.assets.initialize_on_precompile = false
eos
end

inject_into_file 'config/environments/development.rb', :after => "config.assets.debug = true\n" do
<<eos

  config.action_mailer.default_url_options = { :host => 'localhost:3000' }
eos
end

inject_into_file 'config/environments/test.rb', :after => "config.active_support.deprecation = :stderr\n" do
<<eos

  config.action_mailer.default_url_options = { :host => 'localhost:3000' }
eos
end

inject_into_file 'config/environments/production.rb', :after => "# config.active_record.auto_explain_threshold_in_seconds = 0.5\n" do
<<eos

  # TODO Change default host
  config.action_mailer.default_url_options = { :host => 'changeme.com' }

  ActionMailer::Base.smtp_settings = {
  :address        => 'smtp.sendgrid.net',
  :port           => '587',
  :authentication => :plain,
  :user_name      => ENV['SENDGRID_USERNAME'],
  :password       => ENV['SENDGRID_PASSWORD'],
  :domain         => 'dailyarchyve.com'
  }
  ActionMailer::Base.delivery_method ||= :smtp
eos
end

inject_into_file 'app/assets/stylesheets/bootstrap_and_overrides.css.less', :after => "@import \"twitter/bootstrap/bootstrap\";\n" do
<<eos
@media (min-width: 980px) {
  body {
    padding-top: 60px;
    padding-bottom: 42px;
  }
}
eos
end

inject_into_file 'app/helpers/application_helper.rb', :after => "module ApplicationHelper\n" do
<<'eos'
  ALERT_TYPES = [:error, :info, :success, :warning]

  def bootstrap_flash
    flash_messages = []
    flash.each do |type, message|
      # Skip empty messages, e.g. for devise messages set to nothing in a locale file.
      next if message.blank?
      type = :success if type == :notice
      type = :error   if type == :alert
      next unless ALERT_TYPES.include?(type)

      Array(message).each do |msg|
        text = content_tag(:div,
                           content_tag(:button, raw("&times;"), :class => "close", "data-dismiss" => "alert") +
                           msg, :class => "alert fade in alert-#{type}")
        flash_messages << text if message
      end
    end
    flash_messages.join("\n").html_safe
  end
eos
end

run 'bundle exec guard init rspec'

if devise
  migration_file = Dir['db/migrate/*_devise_create_users.rb'].first
  puts migration_file
  gsub_file migration_file, "# t.string",   "t.string"
  gsub_file migration_file, "# t.datetime", "t.datetime"
  gsub_file migration_file, "# t.integer",  "t.integer"
  gsub_file migration_file, "# add_index",  "add_index"
end

run 'rake db:migrate'

append_file '.gitignore' do
  '.DS_Store'
  'config/database.yml'
end

generate "controller pages index --no-helper --no-assets"
gsub_file "config/routes.rb", "# root :to => 'welcome#index'", "root :to => 'pages#index'"
gsub_file "config/routes.rb", "  get \"pages/index\"\n", ""

run "curl https://raw.github.com/gist/2253296/newrelic.yml > config/newrelic.yml"

git :init
git :add => "."
git :commit => "-m 'Setup base Rails app for Heroku with Devise, Slim, #{'ActiveAdmin, ' if active_admin}Rspec, Capybara, FactoryGirl, Guard and Twitter Bootstrap.'"

puts "######################################"
puts "heroku create"
puts "heroku addons:add sendgrid:starter"
puts "heroku addons:add newrelic:standard"
puts "######################################"

