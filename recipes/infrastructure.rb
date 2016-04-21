gem 'foreman'
gem 'redis'
gem 'rollbar'
gem 'unicorn', group: :production
gem "dotenv-rails", group: [:development, :test]

copy_file "templates/infrastructure/Procfile", "Procfile"
copy_file "templates/infrastructure/unicorn.rb", "config/unicorn.rb"
copy_file "templates/infrastructure/redis.rb", "config/initializers/redis.rb"

empty_directory "app/presenters"
empty_directory "app/services"
create_file "app/presenters/.gitkeep"
create_file "app/services/.gitkeep"
create_file ".env"

application(nil, env: "development") do
  "config.action_mailer.default_url_options = { :host => 'localhost:3000' }\n"
end

application(nil, env: "test") do
  "config.action_mailer.default_url_options = { :host => 'localhost:3000' }\n"
end

append_file ".gitignore" do
  <<-EOS
.DS_Store
.env
  EOS
end

inject_into_file "Gemfile", after: "source 'https://rubygems.org'\n" do
  "ruby '2.3.0'\n"
end

create_file ".ruby-version" do
  <<-EOS
2.3.0
  EOS
end

after_bundle do
  generate "rollbar"
end
