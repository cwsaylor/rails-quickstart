pg_user = ask("PostgreSQL user name")
run 'cp config/database.yml config/database.yml.example'
gsub_file "config/database.yml", /username: .*$/, "username: #{pg_user}"

inject_into_file "config/database.yml", :before => "  adapter: postgresql" do
  "  min_messages: WARNING\n"
end

remove_file 'public/index.html'
remove_file 'app/views/layouts/application.html.erb'
remove_file 'app/assets/images/rails.png'
remove_file 'README'
create_file 'Procfile' do
  "web: bundle exec thin start -p $PORT"
end

create_file 'env.example'

create_file '.slugignore' do
  <<-EOS
/spec
/doc
  EOS
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

gem 'slim-rails'
gem 'simple_form'
gem 'newrelic_rpm'
gem 'foreman'
gem 'thin'
gem 'libv8', '~> 3.11.8'
gem 'twitter-bootstrap-rails', :git => 'git://github.com/seyhunak/twitter-bootstrap-rails.git'

if yes?('ActiveAdmin')
  gem 'activeadmin'
  active_admin = true
end

if yes?('Devise')
  gem 'devise'
  devise = true
end

if yes?('Delayed Job')
  gem 'delayed_job_active_record'
  gem 'hirefireapp'
  append_file "Procfile" do
    "\nworker: bundle exec rake jobs:work"
  end
  dj = true
end

inject_into_file "Gemfile", :after => "source 'https://rubygems.org'\n" do
  'ruby "1.9.3"'
end

inject_into_file 'Gemfile', :after => /gem 'uglifier'.*'\n/ do
  <<-EOS
  gem 'therubyracer', :platforms => :ruby
  gem 'less-rails'
  EOS
end

run "bundle install"
run 'rake db:create'

generate "rspec:install"
generate "bootstrap:install less"
generate "bootstrap:layout application fixed"
generate "simple_form:install --bootstrap"
generate "devise:install"            if devise
generate "devise user"               if devise
generate "devise:views"              if devise
generate "active_admin:install"      if active_admin
generate "delayed_job:active_record" if dj

inject_into_file 'spec/spec_helper.rb', :after => "require 'rspec/autorun'\n" do
  "require 'capybara/rspec'\n"
end

inject_into_file 'spec/spec_helper.rb', :after => "RSpec.configure do |config|\n" do
  "  config.include FactoryGirl::Syntax::Methods\n\n"
end

inject_into_file 'config/application.rb', :after => "# config.autoload_paths += %W(\#{config.root}/extras)\n" do
  "    config.autoload_paths += %W(\#{config.root}/lib)\n"
end

if active_admin
  inject_into_file 'config/application.rb', :after => "config.assets.version = '1.0'\n" do
    "\n    config.assets.precompile += %w[active_admin.css active_admin.js active_admin/print.css]\n"
  end
end

inject_into_file 'config/application.rb', :after => "config.assets.version = '1.0'\n" do
  "\n    config.assets.initialize_on_precompile = false\n"
end

inject_into_file 'config/environments/development.rb', :after => "config.assets.debug = true\n" do
  "\n  config.action_mailer.default_url_options = { :host => 'localhost:3000' }\n"
end

inject_into_file 'config/environments/test.rb', :after => "config.active_support.deprecation = :stderr\n" do
  "\n  config.action_mailer.default_url_options = { :host => 'localhost:3000' }\n"
end

inject_into_file 'config/environments/production.rb', :after => "# config.active_record.auto_explain_threshold_in_seconds = 0.5\n" do
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

inject_into_file 'app/assets/stylesheets/bootstrap_and_overrides.css.less', :after => "@import \"twitter/bootstrap/bootstrap\";\n" do
  <<-EOS
@media (min-width: 980px) {
  body {
    padding-top: 60px;
    padding-bottom: 42px;
  }
}
  EOS
end

inject_into_file 'app/helpers/application_helper.rb', :after => "module ApplicationHelper\n" do
  <<-'EOS'
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
gsub_file "config/routes.rb", "# root :to => 'welcome#index'", "root :to => 'pages#index'"
gsub_file "config/routes.rb", "  get \"pages/index\"\n", ""

run "curl https://raw.github.com/gist/2253296/newrelic.yml > config/newrelic.yml"

git :init
git :add => "."
git :commit => "-m 'Setup base Rails app for Heroku with #{'ActiveAdmin, ' if active_admin}#{'Delayed Job, ' if dj}Capybara, #{'Devise, ' if devise}FactoryGirl, Foreman, Guard, New Relic, Rspec, Sendgrid, Slim, Thin, Twitter Bootstrap.'"

puts "######################################"
puts "heroku create"
puts "git push heroku master"
puts "heroku addons:add sendgrid:starter"
puts "heroku addons:add newrelic:standard"
puts "heroku run rake db:migrate"
puts "heroku restart"
puts "heroku addons:open sendgrid"
puts "heroku addons:open newrelic"
puts "heroku ps:scale worker=1" if dj
puts "######################################"

