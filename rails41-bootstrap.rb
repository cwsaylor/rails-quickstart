# TODO Style devise forms for bootstrap for gem
# TODO Add forms to style guide
# TODO Move templates into gem
# TODO Make project name dynamic and update changeme
# TODO Output readme with readme command
# TODO Add a footer to application layout

path = "https://raw.githubusercontent.com/cwsaylor/rails-quickstart/master/templates/"

gem_group :test, :development do
  gem 'byebug'
end

gem_group :production do
  gem 'newrelic_rpm'
  gem 'rails_12factor'
  gem 'unicorn'
end

gem 'autoprefixer-rails'
gem 'bootstrap_form'
gem 'bootstrap-sass', '~> 3.2.0'
gem 'devise'
gem 'foreman'
gem 'slim-rails'

inject_into_file "Gemfile", :after => "source 'https://rubygems.org'\n" do
  "ruby '2.1.3'\n"
end

run "bundle install"
generate "devise:install"
generate "devise user"
generate "devise:views"
run "bundle exec rake db:create"
# Don't run migrate so you can customize the devise migration
#run "bundle exec rake db:migrate"

run "erb2slim -d app/views/devise"

generate "controller pages index --no-helper --no-assets --no-test-framework"

route "get '/styleguide', to: 'pages#styleguide', as: :styleguide"
route "root to: 'pages#index'"

remove_file "app/views/layouts/application.html.erb"
remove_file "app/assets/stylesheets/application.css"

get path + "bootstrap/application.html.slim", "app/views/layouts/application.html.slim"
get path + "bootstrap/navbar.html.slim", "app/views/layouts/_navbar.html.slim"
get path + "bootstrap/styleguide.html.erb", "app/views/pages/styleguide.html.erb"
get path + "bootstrap/index.html.slim", "app/views/pages/index.html.slim"
get path + "holder.js", "vendor/assets/javascripts/holder.js"

run "curl https://gist.githubusercontent.com/rwdaigle/2253296/raw/newrelic.yml > config/newrelic.yml"

create_file "app/assets/stylesheets/application.css.scss" do
  <<-EOS
@import "bootstrap-sprockets";
@import "bootstrap";
@import "rails_bootstrap_forms";
/*@import "bootstrap/theme";*/
  EOS
end

gsub_file "app/assets/javascripts/application.js", "turbolinks", "bootstrap-sprockets"

inject_into_file 'app/assets/javascripts/application.js', :before => "//= require_tree ." do
  "//= require holder\n"
end

append_file ".gitignore" do
  <<-EOS
.DS_Store
.env
  EOS
end

create_file ".slugignore" do
  <<-EOS
/test
/doc
  EOS
end

#inject_into_file 'config/environments/development.rb', :before => /^end$/ do
application(nil, env: "development") do
  "config.action_mailer.default_url_options = { :host => 'localhost:3000' }\n"
end

application(nil, env: "test") do
  "config.action_mailer.default_url_options = { :host => 'localhost:3000' }\n"
end

application(nil, env: "production") do
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

create_file "Procfile" do
  "web: bundle exec unicorn -p $PORT -c ./config/unicorn.rb"
end

create_file "config/unicorn.rb" do
  <<-EOS
worker_processes Integer(ENV["WEB_CONCURRENCY"] || 3)
timeout 15
preload_app true

before_fork do |server, worker|
  Signal.trap 'TERM' do
    puts 'Unicorn master intercepting TERM and sending myself QUIT instead'
    Process.kill 'QUIT', Process.pid
  end

  defined?(ActiveRecord::Base) and
    ActiveRecord::Base.connection.disconnect!
end

after_fork do |server, worker|
  Signal.trap 'TERM' do
    puts 'Unicorn worker intercepting TERM and doing nothing. Wait for master to send QUIT'
  end

  defined?(ActiveRecord::Base) and
    ActiveRecord::Base.establish_connection
end
  EOS
end

create_file ".env" do
  <<-EOS
RACK_ENV=development
PORT=5000
NEW_RELIC_APP_NAME=CHANGEME
  EOS
end

append_to_file 'test/test_helper.rb' do
  <<-EOS

class ActionController::TestCase
  include Devise::TestHelpers
end

  EOS
end

run "bundle exec spring binstub --all"

git :init
git :add => "."
git :commit => "-m 'Setup base Rails 4.1 app.'"

#puts "################################################################################"
#puts "heroku create"
#puts "heroku addons:add newrelic:stark"
#puts "git push heroku master"
#puts "heroku config:set NEW_RELIC_APP_NAME=APP_NAME"
#puts "heroku run rake db:migrate"
#puts "heroku restart"
#puts "heroku addons:open newrelic"
#puts "################################################################################"

