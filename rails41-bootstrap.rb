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

gem 'autoprefixer-rails'
gem 'bootstrap_form'
gem 'bootstrap-sass', '~> 3.2.0'
gem 'devise'
gem 'foreman'
gem 'slim-rails'

inject_into_file "Gemfile", :after => "source 'https://rubygems.org'\n" do
  "ruby '2.1.4'\n"
end

run "bundle install"
generate "devise:install"
generate "devise user"
#generate "devise:views"
run "bundle exec rake db:create"
# Don't run migrate so you can customize the devise migration
#run "bundle exec rake db:migrate"

generate "controller pages --no-helper --no-assets --no-test-framework"

route "get '/styleguide', to: 'pages#styleguide', as: :styleguide"
route "root to: 'pages#index'"

remove_file "app/views/layouts/application.html.erb"
remove_file "app/assets/stylesheets/application.css"

copy_file "templates/bootstrap/application.html.slim", "app/views/layouts/application.html.slim"
copy_file "templates/bootstrap/application.css.scss", "app/assets/stylesheets/application.css.scss"
copy_file "templates/bootstrap/navbar.html.slim", "app/views/layouts/_navbar.html.slim"
copy_file "templates/bootstrap/styleguide.html.erb", "app/views/pages/styleguide.html.erb"
copy_file "templates/bootstrap/index.html.slim", "app/views/pages/index.html.slim"
copy_file "templates/bootstrap/bootstrap_helper.rb", "app/helpers/bootstrap_helper.rb"
copy_file "templates/holder.js", "vendor/assets/javascripts/holder.js"
copy_file "templates/unicorn.rb", "config/unicorn.rb"
copy_file "templates/powenv", ".powenv"
remove_file "test/fixtures/users.yml"
copy_file "templates/users.yml", "test/fixtures/users.yml"

directory "templates/bootstrap/devise", "app/views/devise"

get "https://gist.githubusercontent.com/rwdaigle/2253296/raw/newrelic.yml", "config/newrelic.yml"

gsub_file "app/views/layouts/application.html.slim", "changeme", app_name.titleize
gsub_file "app/views/layouts/_navbar.html.slim", "changeme", app_name.titleize

inject_into_file 'app/assets/javascripts/application.js', :before => "//= require_tree ." do
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
    :address        => 'smtp.sendgrid.net',
    :port           => '587',
    :authentication => :plain,
    :user_name      => ENV['SENDGRID_USERNAME'],
    :password       => ENV['SENDGRID_PASSWORD'],
    :domain         => '#{app_name}.herokuapp.com'
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
  "web: bundle exec unicorn -p $PORT -c ./config/unicorn.rb"
end

create_file ".env" do
  <<-EOS
RACK_ENV=development
PORT=5000
NEW_RELIC_APP_NAME=#{app_name}
  EOS
end

run "bundle exec spring binstub --all"

git :init
git :add => "."
git :commit => "-m 'Setup base Rails 4.1 app.'"

readme "POST-INSTALL.md"

