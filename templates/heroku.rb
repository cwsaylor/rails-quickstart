puts "Setting up Heroku..."

gem "heroku"

run "bundle install"

gsub_file "config/environments/production.rb", "config.serve_static_assets = false", "config.serve_static_assets = true"

if File.exist? "config/mongoid.yml"
  gsub_file "config/mongoid.yml", "  host: <%= ENV['MONGOID_HOST'] %>", "  uri: <%= ENV['MONGOHQ_URL'] %>"
  gsub_file "config/mongoid.yml", "  port: <%= ENV['MONGOID_PORT'] %>", ""
  gsub_file "config/mongoid.yml", "  username: <%= ENV['MONGOID_USERNAME'] %>", ""
  gsub_file "config/mongoid.yml", "  password: <%= ENV['MONGOID_PASSWORD'] %>", ""
  gsub_file "config/mongoid.yml", "  database: <%= ENV['MONGOID_DATABASE'] %>", ""
end

