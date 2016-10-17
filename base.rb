def source_paths
  [File.expand_path(File.dirname(__FILE__))]
end

app_name = ask("NewRelic application name?")

inject_into_file "Gemfile", after: "source 'https://rubygems.org'\n" do
  "ruby '2.3.1'\n"
end

gem_group :test, :development do
  gem 'dotenv-rails'
  gem 'faker'
  gem 'minitest-reporters'
end

gem 'aasm'
gem 'dalli'
gem 'font-awesome-rails'
gem 'foreman'
gem 'foundation-rails'
gem 'inky-rb', require: 'inky'
gem 'meta_request', group: :development
gem 'newrelic_rpm', group: :production
gem 'premailer-rails'
gem 'rack-timeout', group: :production
gem 'redis'
gem 'rollbar'
gem 'sidekiq'
gem 'slim-rails'

copy_file "files/ruby-version",  ".ruby-version"
copy_file "files/Procfile",      "Procfile"
copy_file "files/puma.rb",       "config/puma.rb"
copy_file "files/slugignore",    ".slugignore"
copy_file "files/active_job.rb", "config/initializers/active_job.rb"
copy_file "files/redis.rb",      "config/initializers/redis.rb"

create_file ".env" do
  <<-EOS
REDIS_URL=redis://localhost:6379
PORT=3000
  EOS
end

append_file ".gitignore" do
  <<-EOS
.DS_Store
.env
  EOS
end

gsub_file "config/environments/development.rb", ":memory_store", ":dalli_store"

application(nil, env: "development") do
  "config.action_mailer.default_url_options = { :host => 'localhost:3000' }\n"
  "config.action_mailer.delivery_method = :smtp"
  "config.action_mailer.smtp_settings = { :address => '127.0.0.1', :port => 1025 }"
end

application(nil, env: "test") do
  "config.action_mailer.default_url_options = { :host => 'localhost:3000' }\n"
end

application(nil, env: "production") do
  <<-EOS

  # TODO Change default host
  config.action_mailer.default_url_options = { :host => 'herokuapp.com' }

  ActionMailer::Base.smtp_settings = {
    :address        => 'smtp.sendgrid.net',
    :port           => '587',
    :authentication => :plain,
    :user_name      => ENV['SENDGRID_USERNAME'],
    :password       => ENV['SENDGRID_PASSWORD'],
    :domain         => 'heroku.com',
    :enable_starttls_auto => true
  }
  ActionMailer::Base.delivery_method ||= :smtp

  config.cache_store = :dalli_store,
                      (ENV["MEMCACHIER_SERVERS"] || "").split(","),
                      { :username => ENV["MEMCACHIER_USERNAME"],
                        :password => ENV["MEMCACHIER_PASSWORD"],
                        :failover => true,
                        :socket_timeout => 1.5,
                        :socket_failure_delay => 0.2,
                        :down_retry_delay => 60
                      }

  EOS
end

run "bundle install"

after_bundle do
  run "bundle exec rails db:create"

  generate "controller pages index --no-helper --no-assets"
  route "root to: 'pages#index'"

  generate "rollbar"
  generate "inky:install"
  generate "foundation:install -s"

  remove_file "app/views/layouts/application.html.erb"
  remove_file "app/assets/stylesheets/application.css"
  remove_file "app/assets/javascripts/application.js"

  copy_file "files/application.html.slim", "app/views/layouts/application.html.slim"
  copy_file "files/_menu.html.slim",       "app/views/layouts/_menu.html.slim"
  copy_file "files/application.scss",      "app/assets/stylesheets/application.scss"
  copy_file "files/_card.scss",            "app/assets/stylesheets/_card.scss"
  copy_file "files/application.js",        "app/assets/javascripts/application.js"

  prepend_file "config/routes.rb", "require 'sidekiq/web'\n"
  route "mount Sidekiq::Web => '/sidekiq'"

  append_file "config/initializers/assets.rb", "Rails.application.config.assets.precompile += %w( foundation_emails.css )"

  run %Q(bundle exec newrelic install --license_key="'<%= ENV["NEW_RELIC_LICENSE_KEY"] %>'" "#{app_name}")

  git :init
  git :add => "."
  git :commit => "-m 'Setup Rails #{Rails::VERSION::STRING} app with Rails Quickstart'"
end
