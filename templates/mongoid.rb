puts "Setting up Mongoid..."

run "rm config/database.yml"

gsub_file "Gemfile", "gem 'sqlite3-ruby'", "# gem 'sqlite3-ruby'"

gem "mongoid", "2.0.0.rc.6"
gem "bson_ext", "~> 1.2"

run "bundle install"

application "  config.generators.orm :mongoid"

generate "mongoid:config"

gsub_file "config/application.rb", "require 'rails/all'" do
  <<-RUBY
require "mongoid/railtie"
require "action_controller/railtie"
require "action_mailer/railtie"
require "active_resource/railtie"
require "rails/test_unit/railtie"
  RUBY
end

gsub_file "test/test_helper.rb", /end/ do
  <<-RUBY
  setup :drop_collections

  private

  def drop_collections
    Mongoid.master.collections.select {|c| c.name !~ /system/ }.each(&:drop)
  end
end
  RUBY
end
