# Application Generator Template
# Modifies a Rails app to use Mongoid, Devise, HTML5, Formtastic, jQuery

#TODO Setup mail for heroku addon
#TODO Generate formatastic forms for devise

puts "Setting up a new Rails 3 app for Mongoid/AR, Devise, Formtastic, Factory Girl, HTML5, jQuery..."

site_name = ask("What is the name of the site?")
domain    = ask("What domain would you like to use?")
email     = ask("What email would you like to send from?")
user      = ask("What would you like to call your devise model? e.g. User")
mongo     = ask("Use Mongo? y/n")

if mongo == "n"
  db_user = ask("What's the db username?")
end

orm               = mongo == "y" ? "mongoid" : "active_record"
user_file_name    = user.underscore.singularize
user_factory_file = user.underscore.pluralize
user_model_name   = user.classify

#----------------------------------------------------------------------------
# Remove the usual cruft
#----------------------------------------------------------------------------
puts "removing unneeded files..."

if mongo == "y"
  run 'rm config/database.yml'
end

run 'rm public/index.html'
run 'rm public/images/rails.png'
run 'rm public/javascripts/controls.js'
run 'rm public/javascripts/dragdrop.js'
run 'rm public/javascripts/effects.js'
run 'rm public/javascripts/prototype.js'
run 'rm public/javascripts/rails.js'
run 'rm README'
run 'touch README'

#----------------------------------------------------------------------------
# Download jQuery and rails ujs
#----------------------------------------------------------------------------
run 'curl -L http://code.jquery.com/jquery-1.4.2.min.js > public/javascripts/jquery-1.4.2.min.js'
run 'curl -L http://github.com/rails/jquery-ujs/raw/master/src/rails.js > public/javascripts/rails.js'

#----------------------------------------------------------------------------
# Download stylesheets
#----------------------------------------------------------------------------
run 'curl -L http://github.com/cwsaylor/rails3-quickstart/raw/master/stylesheets/reset.css > public/stylesheets/reset.css'
run 'curl -L http://github.com/cwsaylor/rails3-quickstart/raw/master/stylesheets/application.css > public/stylesheets/application.css'

#----------------------------------------------------------------------------
# Add gems to Gemfile
#----------------------------------------------------------------------------
puts "installing gems..."

gsub_file 'Gemfile', /gem \'sqlite3-ruby/, '# gem \'sqlite3-ruby'

if mongo == "y"
  gem 'mongoid', '2.0.0.beta.17'
  gem 'bson_ext', '1.0.4'
end

gem 'devise', :git => 'http://github.com/plataformatec/devise.git'
gem 'formtastic'
gem 'factory_girl_rails'
gem 'rails3-generators', :group => :development

run 'bundle install'

#----------------------------------------------------------------------------
# Tweak config/application.rb for Mongoid, Factory Girl, jQuery
#----------------------------------------------------------------------------
puts "updating config/application.rb with the orm, factory girl and jquery..."

gsub_file 'config/application.rb', /# Configure the default encoding used in templates for Ruby 1.9./ do
<<-FILE
config.generators do |g|
      g.orm             :#{orm}
      g.test_framework  :test_unit, :fixture_replacement => :factory_girl
    end
    
    # Use jQuery for RJS
    config.action_view.javascript_expansions[:defaults] = ['jquery-1.4.2.min', 'rails']
    
    # Configure the default encoding used in templates for Ruby 1.9.
FILE
end

#----------------------------------------------------------------------------
# Prevent logging of passwords
#----------------------------------------------------------------------------
puts "prevent logging of passwords..."

gsub_file 'config/application.rb', /:password/, ':password, :password_confirmation'

#----------------------------------------------------------------------------
# Remove fixtures
#----------------------------------------------------------------------------
puts "death to fixtures..."
run 'rmdir test/fixtures'
gsub_file 'test/test_helper.rb', /fixtures :all/, "# fixtures :all"

#----------------------------------------------------------------------------
# Setup Database
#----------------------------------------------------------------------------
if mongo == "n"
  # puts "creating the database..."
  gsub_file 'config/database.yml', /username: .*/, "username: #{db_user}"
  # rake 'db:create' 
end

#----------------------------------------------------------------------------
# Setup Mongoid
#----------------------------------------------------------------------------
if mongo == "y"
  puts "setting up Mongo..."
  generate "mongoid:config"

  gsub_file 'config/application.rb', /require 'rails\/all'/ do
    <<-RUBY
# If you are deploying to Heroku and MongoHQ,
# you supply connection information here.
require 'uri'
if ENV['MONGOHQ_URL']
  mongo_uri = URI.parse(ENV['MONGOHQ_URL'])
  ENV['MONGOID_HOST'] = mongo_uri.host
  ENV['MONGOID_PORT'] = mongo_uri.port.to_s
  ENV['MONGOID_USERNAME'] = mongo_uri.user
  ENV['MONGOID_PASSWORD'] = mongo_uri.password
  ENV['MONGOID_DATABASE'] = mongo_uri.path.gsub('/', '')
end

require 'mongoid/railtie'
require 'action_controller/railtie'
require 'action_mailer/railtie'
require 'active_resource/railtie'
require 'rails/test_unit/railtie'
    RUBY
  end

  gsub_file 'test/test_helper.rb', /end/ do <<-FILE
  setup :drop_collections

  private

  def drop_collections
    Mongoid.master.collections.select {|c| c.name !~ /system/ }.each(&:drop)
  end
end
  FILE
  end
end

#----------------------------------------------------------------------------
# Set up Devise
#----------------------------------------------------------------------------
puts "setting up devise..."

generate "devise:install"

gsub_file 'config/initializers/devise.rb', /please-change-me@config-initializers-devise.com/, email
gsub_file 'config/environments/development.rb', /# Don't care if the mailer can't send/, '### ActionMailer Config'
gsub_file 'config/environments/development.rb', /config.action_mailer.raise_delivery_errors = false/ do
<<-RUBY
config.action_mailer.default_url_options = { :host => 'localhost:3000' }
  # A dummy setup for development - no deliveries, but logged
  config.action_mailer.delivery_method = :smtp
  config.action_mailer.perform_deliveries = false
  config.action_mailer.raise_delivery_errors = true
  config.action_mailer.default :charset => "utf-8"
RUBY
end
gsub_file 'config/environments/production.rb', /config.i18n.fallbacks = true/ do
<<-RUBY
config.i18n.fallbacks = true

  config.action_mailer.default_url_options = { :host => '#{domain}' }
  ### ActionMailer Config
  # Setup for production - deliveries, no errors raised
  config.action_mailer.delivery_method = :smtp
  config.action_mailer.perform_deliveries = true
  config.action_mailer.raise_delivery_errors = false
  config.action_mailer.default :charset => "utf-8"
RUBY
end

generate :devise, user
generate "devise:views"

gsub_file "app/models/#{user_file_name}.rb", /^end$/ do
<<-RUBY
  attr_accessible :email, :password, :password_confirmation
end
RUBY
end

gsub_file "test/factories/#{user_factory_file}.rb", /^end$/ do
<<-'RUBY'
  f.sequence(:email) {|n| "person#{n}@example.com" }
  f.password "testing"
  f.password_confirmation "testing"
end
RUBY
end

puts "creating a default user..."
append_file 'db/seeds.rb' do <<-FILE
puts 'SETTING UP DEFAULT USER LOGIN'
#{user_file_name} = #{user_model_name}.create! :email => 'user@domain.com', :password => 'change_me', :password_confirmation => 'change_me'
puts 'New user created: ' << #{user_file_name}.email
FILE
end
# rake 'db:seed'

#----------------------------------------------------------------------------
# Set up Formtastic
#----------------------------------------------------------------------------
puts "setting up formtastic..."
generate 'formtastic:install'
#run 'rm public/stylesheets/formtastic.css'
#run 'rm public/stylesheets/formtastic_changes.css'

#----------------------------------------------------------------------------
# Set up Heroku
#----------------------------------------------------------------------------
puts "setting serve_static_assets to true for heroku..."
gsub_file 'config/environments/production.rb', /config.serve_static_assets = false/, "config.serve_static_assets = true"

#----------------------------------------------------------------------------
# Generate Application Layout
#----------------------------------------------------------------------------
run 'rm app/views/layouts/application.html.erb'
create_file 'app/views/layouts/application.html.erb' do <<-FILE
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="utf-8" />
  <title>#{site_name}</title>
  <%= stylesheet_link_tag 'reset', 'formtastic', 'application' %>
  <%= javascript_include_tag :defaults %>
  <%= csrf_meta_tag %>
</head>
<body>

  <div id="header">
    <div class="row">
      <div class="column grid_12">
        <h1>#{site_name}</h1>
      </div>
    </div>
  </div>
  
  <div id="content">
    <div class="row">
      <div class="column grid_12">
        <%= yield %>
      </div>
    </div>  
  </div>
  
  <div id="footer">
    <div class="row">
      <div class="column grid_12">
        <p>&copy; #{Time.now.year} #{site_name}</p>
      </div>
    </div>  
  </div>

</body>
</html>
FILE
end

#----------------------------------------------------------------------------
# Set up git
#----------------------------------------------------------------------------
puts "committing to 'git'..."
# specific to Mac OS X
append_file '.gitignore' do
  '.DS_Store'
end
git :init
git :add => '.'
git :commit => "-m 'Initial commit of our rails app.'"

puts <<-FILE

Next Steps:

Edit the devise model and migration to enable additional features

rake db:create
rake db:migrate
rake db:seed

Login with user@domain.com and change_me

FILE
