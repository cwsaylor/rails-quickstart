# Application Generator Template
# Modifies a Rails app to use Mongoid, Devise, HTML5, Formtastic, jQuery, Heroku

#TODO Setup mail for heroku addon
#TODO Generate formatastic forms for devise

puts "Setting up a new Rails 3 app for Mongoid, Devise, Formtastic, Factory Girl, HTML5, jQuery, Heroku..."

domain = ask("What domain would you like to use?")
email = ask("What email would you like to send from?")
user = ask("What would you like to call your devise model? e.g. User")
grid = ask("Which grid would you like to use? [1]fixed or [2]flex?")

grid_file = grid.to_i == 1 ? "grid" : "flex_grid"

user_file_name = user.underscore.singularize
user_factory_file = user.underscore.pluralize
user_model_name = user.classify

#----------------------------------------------------------------------------
# Remove the usual cruft
#----------------------------------------------------------------------------
puts "removing unneeded files..."
run 'rm config/database.yml'
run 'rm public/index.html'
run 'rm public/favicon.ico'
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
# jQuery 1.4.2 is broken
run 'curl -L http://code.jquery.com/jquery-1.4.1.min.js > public/javascripts/jquery-1.4.1.js'
run 'curl -L http://github.com/rails/jquery-ujs/raw/master/src/rails.js > public/javascripts/rails.js'

#----------------------------------------------------------------------------
# Add gems to Gemfile
#----------------------------------------------------------------------------
puts "Adding gems to Gemfile..."
gsub_file 'Gemfile', /gem \'sqlite3-ruby/, '# gem \'sqlite3-ruby'
gem 'mongoid', '2.0.0.beta.16'
gem 'bson_ext', '1.0.4'
gem "devise", :git => "http://github.com/plataformatec/devise.git"
gem 'formtastic', :git => "http://github.com/justinfrench/formtastic.git", :branch => "rails3"
gem 'flutie'
gem "factory_girl_rails"
gem 'heroku', '1.9.13', :group => :development
gem "rails3-generators", '0.12.1', :group => :development
gem 'autotest', :group => :test
gem 'autotest-rails', :group => :test
gem 'test_notifier', :group => :test

puts "installing gems (takes a few minutes!)..."
run 'bundle install'

#----------------------------------------------------------------------------
# Tweak config/application.rb for Mongoid, Factory Girl, jQuery and
# prevent password logging
#----------------------------------------------------------------------------
puts "updating config/application.rb"
gsub_file 'config/application.rb', /# Configure the default encoding used in templates for Ruby 1.9./ do
<<-RUBY
config.generators do |g|
      g.orm             :mongoid
      g.test_framework  :test_unit, :fixture_replacement => :factory_girl
    end
    
    # Use jQuery for RJS
    config.action_view.javascript_expansions[:defaults] = ['jquery-1.4.1', 'rails']
    
    # Configure the default encoding used in templates for Ruby 1.9.
RUBY
end

puts "prevent logging of passwords..."
gsub_file 'config/application.rb', /:password/, ':password, :password_confirmation'

#----------------------------------------------------------------------------
# Setup Mongoid
#----------------------------------------------------------------------------
puts "creating 'config/mongoid.yml' Mongoid configuration file..."
generate "mongoid:config"

puts "modifying 'config/application.rb' file for Mongoid..."
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

#----------------------------------------------------------------------------
# Setup testing for Mongoid and test_notifier
#----------------------------------------------------------------------------
run 'rmdir test/fixtures'
gsub_file 'test/test_helper.rb', /fixtures :all/, "# fixtures :all"
gsub_file 'test/test_helper.rb', /require 'rails\/test_help'/ do <<-FILE
require 'rails/test_help'
require "test_notifier/runner/test_unit"
FILE
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

#----------------------------------------------------------------------------
# Set up Devise
#----------------------------------------------------------------------------
puts "creating 'config/initializers/devise.rb' Devise configuration file..."
generate "devise:install"

puts "modifying environment configuration files for Devise..."
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
  validates_uniqueness_of :email
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
rake 'db:seed'

#----------------------------------------------------------------------------
# Set up Formtastic and replace stylesheets with flutie
#----------------------------------------------------------------------------
generate 'formtastic:install'
rake 'flutie:install'
run 'rm public/stylesheets/formtastic.css'
run 'rm public/stylesheets/formtastic_changes.css'

#----------------------------------------------------------------------------
# Set up Heroku
#----------------------------------------------------------------------------
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
  <title>#{domain}</title>
  <%= stylesheet_link_tag :flutie, '#{grid_file}', 'application' %>
  <%= javascript_include_tag :defaults %>
  <%= csrf_meta_tag %>
</head>
<body>

<div class="row">
	<div class="column grid_12">
	  <h1>#{domain}</h1>
	</div>
</div>


<div class="row">
	<div class="column grid_12">
	  <%= yield %>
	</div>
</div>

</body>
</html>
FILE
end

create_file 'public/stylesheets/grid.css' do <<-FILE
/* ================ */
/* = The 1Kb Grid = */     /* 12 columns, 60 pixels each, with 20 pixel gutter */
/* ================ */

.grid_1 { width:60px; }
.grid_2 { width:140px; }
.grid_3 { width:220px; }
.grid_4 { width:300px; }
.grid_5 { width:380px; }
.grid_6 { width:460px; }
.grid_7 { width:540px; }
.grid_8 { width:620px; }
.grid_9 { width:700px; }
.grid_10 { width:780px; }
.grid_11 { width:860px; }
.grid_12 { width:940px; }

.column {
	margin: 0 10px;
	overflow: hidden;
	float: left;
	display: inline;
}
.row {
	width: 960px;
	margin: 0 auto;
	overflow: hidden;
}
.row .row {
	margin: 0 -10px;
	width: auto;
	display: inline-block;
}
FILE
end

create_file 'public/stylesheets/flex_grid.css' do <<-FILE
/* ================== */
/* = 960 Flex Grid = */
/* ================== */

.grid_1 { width:6.25%; } /* 60 */
.grid_2 { width:14.583%; } /* 140 */
.grid_3 { width:22.917%; } /* 220 */
.grid_4 { width:31.25%; } /* 300 */
.grid_5 { width:41.667%; } /* 380 */
.grid_6 { width:47.917%; } /* 460 */
.grid_7 { width:56.25%; } /* 540 */
.grid_8 { width:64.583%; } /* 620 */
.grid_9 { width:72.917%; } /* 700 */
.grid_10 { width:81.25%; } /* 780 */
.grid_11 { width:89.583%; } /* 860 */
.grid_12 { width:97.917%; } /* 940 */

.column {
	margin: 0 1.04%;
	overflow: hidden;
	float: left;
}
.row {
	min-width: 960px;
	width: 97.875%;
	margin: 0 1.064%;
	overflow: hidden;
}
.row .row {
	width: auto;
	margin: 0 -1.04%;
}
FILE
end

create_file 'public/stylesheets/application.css' do <<-FILE
body {
  background-color: #d4d2da;
  margin-top: 10px;
}
.row {
  background-color: white;
}
p, dl, hr, h1, h2, h3, h4, h5, h6, ol, ul, pre, table, address, fieldset { 
  margin-bottom: 10px;
}

.top {
  padding-top: 10px;
  -webkit-border-top-left-radius: 10px;
  -webkit-border-top-right-radius: 10px;
  -moz-border-radius-topleft: 10px;
  -moz-border-radius-topright: 10px;
  border-top-left-radius: 10px;
  border-top-right-radius: 10px;
}

.bottom {
  -webkit-border-bottom-right-radius: 10px;
  -webkit-border-bottom-left-radius: 10px;
  -moz-border-radius-bottomright: 10px;
  -moz-border-radius-bottomleft: 10px;
  border-bottom-right-radius: 10px;
  border-bottom-left-radius: 10px;
}
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
git :commit => "-m 'Initial commit of our rails app for Mongoid, Devise, Formtastic, Factory Girl, HTML5, jQuery, Heroku'"
