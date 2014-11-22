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

gem 'devise'
gem 'foreman'
gem 'foundation-rails'
gem 'simple_form'
gem 'slim-rails'

inject_into_file "Gemfile", :after => "source 'https://rubygems.org'\n" do
  "ruby '2.1.5'\n"
end

run "bundle install"
generate "devise:install"
generate "devise user"
#generate "devise:views"
generate "foundation:install"
generate "simple_form:install --foundation"

devise_migration = Dir["db/migrate/*devise_create_users.rb"].first
gsub_file(devise_migration, "# t", "t")
gsub_file(devise_migration, "# add_index", "add_index")

run "bundle exec rake db:create"
run "bundle exec rake db:migrate"

generate "controller pages --no-helper --no-assets --no-test-framework"

#route "get '/styleguide', to: 'pages#styleguide', as: :styleguide"
route "root to: 'pages#index'"

remove_file "app/views/layouts/application.html.erb"
remove_file "app/assets/stylesheets/application.css"
remove_file "test/fixtures/users.yml"

copy_file "templates/foundation/application.html.slim", "app/views/layouts/application.html.slim"
copy_file "templates/foundation/application.css.scss", "app/assets/stylesheets/application.css.scss"
copy_file "templates/foundation/navbar.html.slim", "app/views/layouts/_navbar.html.slim"
#copy_file "templates/foundation/styleguide.html.erb", "app/views/pages/styleguide.html.erb"
copy_file "templates/foundation/index.html.slim", "app/views/pages/index.html.slim"
copy_file "templates/foundation/flash_helper.rb", "app/helpers/flash_helper.rb"
copy_file "templates/foundation/interchange_helper.rb", "app/helpers/interchange_helper.rb"
copy_file "templates/foundation/simple_form_foundation.rb", "config/initializers/simple_form_foundation.rb"
copy_file "templates/holder.js", "vendor/assets/javascripts/holder.js"
copy_file "templates/modernizr.js", "vendor/assets/javascripts/modernizr.js"
copy_file "templates/unicorn.rb", "config/unicorn.rb"
copy_file "templates/powenv", ".powenv"
copy_file "templates/users.yml", "test/fixtures/users.yml"

directory "templates/foundation/devise", "app/views/devise"

get "https://gist.githubusercontent.com/rwdaigle/2253296/raw/newrelic.yml", "config/newrelic.yml"

gsub_file "app/views/layouts/application.html.slim", "changeme", app_name.titleize
gsub_file "app/views/layouts/_navbar.html.slim", "changeme", app_name.titleize

gsub_file "config/initializers/simple_form_foundation.rb", "# b.use :hint", "b.use :hint"

inject_into_file 'app/assets/javascripts/application.js', :before => "//= require_tree ." do
  <<-EOS
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

append_file "config/initializers/assets.rb" do
  <<-EOS
Rails.application.config.assets.precompile += %w( modernizr.js )
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
