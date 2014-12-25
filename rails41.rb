def source_paths
  [File.expand_path(File.dirname(__FILE__))]
end

gem_group :test, :development do
  gem 'byebug'
end

gem_group :production do
  gem 'newrelic_rpm'
  gem 'rails_12factor'
  gem 'unicorn'
end

gem 'activeadmin', github: 'activeadmin'
gem 'autoprefixer-rails'
gem 'bootstrap_form'
gem 'bootstrap-sass'
gem 'bootswatch-rails'
gem 'dalli'
gem 'devise'
gem 'devise-async'
gem 'foreman'
gem 'slim-rails'
gem 'redis'
gem 'resque'

inject_into_file "Gemfile", after: "source 'https://rubygems.org'\n" do
  "ruby '2.1.5'\n"
end

run "bundle install"

generate "devise:install"
generate "devise user"
generate "active_admin:install"
generate "active_admin:resource User"

devise_migration = Dir["db/migrate/*devise_create_users.rb"].first
gsub_file(devise_migration, "# t", "t")
gsub_file(devise_migration, "# add_index", "add_index")

run "bundle exec rake db:create"
run "bundle exec rake db:migrate"

generate "controller pages --no-helper --no-assets --no-test-framework"

route "get '/styleguide', to: 'pages#styleguide', as: :styleguide"
route "root to: 'pages#index'"

remove_file "app/views/layouts/application.html.erb"
remove_file "app/assets/stylesheets/application.css"
remove_file "test/fixtures/users.yml"

copy_file "templates/bootstrap/application.html.slim" , "app/views/layouts/application.html.slim"
copy_file "templates/bootstrap/application.css.scss"  , "app/assets/stylesheets/application.css.scss"
copy_file "templates/bootstrap/navbar.html.slim"      , "app/views/layouts/_navbar.html.slim"
copy_file "templates/bootstrap/styleguide.html.erb"   , "app/views/pages/styleguide.html.erb"
copy_file "templates/bootstrap/index.html.slim"       , "app/views/pages/index.html.slim"
copy_file "templates/bootstrap/bootstrap_helper.rb"   , "app/helpers/bootstrap_helper.rb"
copy_file "templates/admin/mailers.rb"                , "app/admin/mailers.rb"
copy_file "templates/initializers/redis.rb"           , "config/initializers/redis.rb"
copy_file "templates/initializers/resque.rb"          , "config/initializers/resque.rb"
copy_file "templates/javascripts/holder.js"           , "vendor/assets/javascripts/holder.js"
copy_file "templates/config/unicorn.rb"               , "config/unicorn.rb"
copy_file "templates/fixtures/users.yml"              , "test/fixtures/users.yml"
copy_file "templates/powenv"                          , ".powenv"

directory "templates/bootstrap/devise", "app/views/devise"

get "https://gist.githubusercontent.com/rwdaigle/2253296/raw/newrelic.yml", "config/newrelic.yml"

gsub_file "app/views/layouts/application.html.slim", "changeme" , app_name.titleize
gsub_file "app/views/layouts/_navbar.html.slim", "changeme" , app_name.titleize
gsub_file "config/environments/production.rb", "# config.cache_store = :mem_cache_store", "config.cache_store = :mem_cache_store"
gsub_file "app/assets/javascripts/application.js", "//= require_tree .\n", ""
gsub_file "app/models/user.rb", "devise", "devise :async,"

inject_into_file "config/routes.rb", after: "ActiveAdmin::Devise\.config\n" do
  <<-EOS
  authenticate :admin_user do
    mount Resque::Server.new, :at => "/jobs"
  end
  EOS
end

append_file "app/assets/javascripts/application.js" do
  <<-EOS
//= require bootstrap-sprockets
//= require holder
  EOS
end

append_file ".gitignore" do
  <<-EOS
.DS_Store
.env
  EOS
end

create_file "config/initializers/devise_async.rb" do
  <<-EOS
Devise::Async.backend = :resque
  EOS
end

create_file ".slugignore" do
  <<-EOS
/test
/doc
  EOS
end

application do
  "config.app_generators.scaffold_controller :scaffold_controller"
end

application(nil, env: "development") do
  "config.action_mailer.default_url_options = { :host => 'localhost:3000' }\n"
end

application(nil, env: "test") do
  "config.action_mailer.default_url_options = { :host => 'localhost:3000' }\n"
end

application(nil, env: "production") do
  <<-EOS
  # TODO Change default host
  config.action_mailer.default_url_options = { :host => '#{app_name}.herokuapp.com' }

  ActionMailer::Base.smtp_settings = {
    :address        => 'smtp.mandrillapp.com',
    :port           => '587',
    :authentication => :plain,
    :user_name      => ENV['MANDRILL_USERNAME'],
    :password       => ENV['MANDRILL_APIKEY'],
    :domain         => 'heroku.com'
  }
  ActionMailer::Base.delivery_method ||= :smtp

  EOS
end

append_to_file 'test/test_helper.rb' do
  <<-EOS

class ActionController::TestCase
  include Devise::TestHelpers
end

  EOS
end

create_file "Procfile" do
  <<-EOS
web: bundle exec unicorn -p $PORT -c ./config/unicorn.rb
resque: env INTERVAL=0.1 QUEUES=* bundle exec rake resque:work
  EOS
end

create_file "lib/tasks/resque.rake" do
  <<-EOS
require 'resque/tasks'

task "resque:setup" => :environment do
  #for redistogo on heroku http://stackoverflow.com/questions/2611747/rails-resque-workers-fail-with-pgerror-server-closed-the-connection-unexpectedl
  Resque.before_fork = Proc.new { ActiveRecord::Base.establish_connection }
end
  EOS
end

create_file ".env" do
  <<-EOS
RACK_ENV=development
PORT=5000
NEW_RELIC_APP_NAME=#{app_name}
QUEUE=*
  EOS
end

run "bundle exec spring binstub --all"

git :init
git :add => "."
git :commit => "-m 'Setup base Rails 4.1 app.'"

