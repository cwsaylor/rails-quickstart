gem_group :test, :development do
  gem 'byebug'
end

gem_group :production do
  gem 'newrelic_rpm'
  gem 'rails_12factor'
  gem 'unicorn'
end

gem 'foundation-rails'
gem 'foreman'
gem 'slim-rails'

inject_into_file "Gemfile", :after => "source 'https://rubygems.org'\n" do
  "ruby '2.1.2'\n"
end

run "bundle install"
run "bundle exec rake db:create"
run "bundle exec rake db:migrate"
generate "foundation:install --slim"

remove_file "app/views/layouts/application.html.erb"
remove_file "app/assets/stylesheets/application.css"

run "curl https://gist.githubusercontent.com/cwsaylor/11094449/raw/application.html.slim > app/views/layouts/application.html.slim"
run "curl https://gist.githubusercontent.com/rwdaigle/2253296/raw/newrelic.yml > config/newrelic.yml"

create_file "app/assets/stylesheets/application.css.scss" do
  <<-EOS
@import "foundation_and_overrides";
/* Add imports of custom sass/scss files here */
  EOS
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

generate "controller pages index --no-helper --no-assets --no-test-framework"

inject_into_file "config/routes.rb", :after => "routes.draw do\n" do
  "  root :to => 'pages#index'\n"
end

run "bundle exec spring binstub --all"

git :init
git :add => "."
git :commit => "-m 'Setup base Rails 4.1 app with Slim, Twitter Bootstrap, Byebug, Heroku, Unicorn and New Relic.'"

puts "################################################################################"
puts "heroku create"
puts "heroku addons:add newrelic:stark"
puts "git push heroku master"
puts "heroku config:set NEW_RELIC_APP_NAME=APP_NAME"
puts "heroku run rake db:migrate"
puts "heroku restart"
puts "heroku addons:open newrelic"
puts "################################################################################"

