puts '######################################################'
puts ' Setting up Mongoid'
puts '######################################################'

gsub_file 'Gemfile', "gem 'sqlite3-ruby", "# gem 'sqlite3-ruby"

gem 'mongoid', '2.0.0.beta.20'
gem 'bson_ext', '1.1.5'

run 'bundle install'

application "  config.generators.orm :mongoid"

generate "mongoid:config"

gsub_file 'config/application.rb', "require 'rails/all'" do
  <<-RUBY
require 'mongoid/railtie'
require 'action_controller/railtie'
require 'action_mailer/railtie'
require 'active_resource/railtie'
require 'rails/test_unit/railtie'
  RUBY
end

gsub_file 'config/mongoid.yml', "  host: <%= ENV['MONGOID_HOST'] %>", "  uri: <%= ENV['MONGOHQ_URL'] %>"
gsub_file 'config/mongoid.yml', "  port: <%= ENV['MONGOID_PORT'] %>", ""
gsub_file 'config/mongoid.yml', "  username: <%= ENV['MONGOID_USERNAME'] %>", ""
gsub_file 'config/mongoid.yml', "  password: <%= ENV['MONGOID_PASSWORD'] %>", ""
gsub_file 'config/mongoid.yml', "  database: <%= ENV['MONGOID_DATABASE'] %>", ""

gsub_file 'test/test_helper.rb', /end/ do
  <<-RUBY
  setup :drop_collections

  private

  def drop_collections
    Mongoid.master.collections.select {|c| c.name !~ /system/ }.each(&:drop)
  end
end
  RUBY
end
