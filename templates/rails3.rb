# Rails 3 Application Generator Template
# Modifies a Rails app to use optionally use Mongoid and Devise
# Also sets up an HTML5 template with 1kb grid, Formtastic and jQuery

#TODO Setup mail for heroku addon
#TODO Generate formatastic forms for devise

remote_template_path = "https://github.com/cwsaylor/rails3-quickstart/raw/master"
local_template_path = File.expand_path(File.join(File.dirname(__FILE__), ".."))

use_haml    = false
use_mongoid = false
use_devise  = false


def agnostic_copy(from_file, to_file)
  if @template_path[0..6] == "http://" || @template_path[0..7] == "https://"
    run "curl -L #{@template_path}/#{from_file} > #{to_file}"
  else
    copy_file "#{@template_path}/#{from_file}", "#{to_file}"
  end
end

puts '######################################################'
puts " Answer a few questions and we'll get you on your way."
puts '######################################################'

site_name = ask("Site name?")
jquery    = ask("jQuery version?")
puts      "Path for additional templates: remote, local, other?"

if yes?("Remote? #{remote_template_path}")
  @template_path = remote_template_path
elsif yes?("Local? #{local_template_path}?")
  @template_path = local_template_path
else
  @template_path = ask("Other?")
end

# This may not work since we are doing substitution!!!!!!!!!!!!!!!!!!!!!
# See template in thor
# http://rdoc.info/github/wycats/thor/master/Thor/Actions#template-instance_method

puts '######################################################'
puts ' Setting up Haml'
puts '######################################################'

gem 'haml-rails'
create_file 'app/views/layouts/application.html.haml' do <<-HAML
!!! 5
%html{ :lang => "en"}
  %head
    %title
      #{site_name}
    %meta{ :charset => 'utf-8' }
    %meta{ :name => 'description', :content => "" }
    %meta{ :name => 'keywords', :content => "" }
    = stylesheet_link_tag :flutie, 'application'
    = javascript_include_tag :defaults
    = csrf_meta_tag
  %body
    #header
      .row
        .column.grid_12
          %h1
            %a{ :href => '/', :title => "" }
              #{site_name}
    - flash.each do |key, value|
      .row{ :class => key } 
        .column.grid_12
          = value
    #content
      .row
        .column.grid_12
          =yield
    #footer
      .row
        .column.grid_12
          %hr
          %p
            &copy; #{Time.now.year} #{site_name}
HAML
end

puts '######################################################'
puts ' Adding base gems to Gemfile'
puts '######################################################'

gem 'formtastic'
gem 'factory_girl_rails'
gem 'jquery-rails'
gem 'rails3-generators', :group => :development
gem 'flutie'
gem 'hpricot'
gem 'ruby_parser'
run 'bundle install'

if yes?("Use Mongoid?")
  run 'rm config/database.yml'
  apply "#{@template_path}/templates/mongoid.rb"
  use_mongoid = true
else
  db_user = ask("What's the db username?")
  gsub_file 'config/database.yml', /username: .*/, "username: #{db_user}"
end

if yes?("Use Devise?")
  apply "#{@template_path}/templates/devise.rb"
  use_devise = true
end

puts '######################################################'
puts ' Removing unused files and empty README'
puts '######################################################'

run 'rm public/index.html'
run 'rm public/images/rails.png'
run 'echo "" > README'

puts '######################################################'
puts ' Downloading base stylesheets'
puts '######################################################'

agnostic_copy "stylesheets/reset.css",        "public/stylesheets/reset.css"
agnostic_copy "stylesheets/application.css",  "public/stylesheets/application.css"

puts '######################################################'
puts ' Setting up Flutie'
puts '######################################################'

rake 'flutie:install'

puts '######################################################'
puts ' Setting up jQuery'
puts '######################################################'

run 'rm public/javascripts/rails.js'
generate "jquery:install --version #{jquery}"

puts '######################################################'
puts ' Setting up Testing Framework'
puts '######################################################'
if yes?("Setup cucumber and rspec?")
  gem "cucumber", :group => [:development, :test]
  gem "cucumber-rails", :group => [:development, :test]
  gem "rspec", :group => [:development, :test]
  gem "rspec-rails", :group => [:development, :test]
  gem "webrat"
  run "bundle install"
  generate "rspec:install"
  generate "cucumber:install", "--force", "--rspec", "--webrat"
  run "rm -rf test/"
  application "  config.generators.test_framework :rspec, :fixture_replacement => :factory_girl"
else
  application "  config.generators.test_framework :test_unit, :fixture_replacement => :factory_girl"
end

puts '######################################################'
puts ' Removing fixtures'
puts '######################################################'

run 'rmdir test/fixtures'
gsub_file 'test/test_helper.rb', 'fixtures :all', "# fixtures :all"

puts '######################################################'
puts ' Preventing logging of password_confirmation'
puts '######################################################'

gsub_file 'config/application.rb', ':password', ':password, :password_confirmation'

puts '######################################################'
puts ' Setting up Formtastic'
puts '######################################################'

generate 'formtastic:install'

if yes?("Setting up Heroku?")
  puts '######################################################'
  puts ' Setting up Heroku'
  puts '######################################################'

  gsub_file 'config/environments/production.rb', 'config.serve_static_assets = false', 'config.serve_static_assets = true'
  # run 'heroku create'
end

puts '######################################################'
puts ' Setting up git'
puts '######################################################'

append_file '.gitignore' do
  '.DS_Store'
end

git :init
git :add => '.'
git :commit => "-m 'Initial commit of our rails app.'"

puts '======================================================'
puts
puts " Edit the devise model and migration to enable"
puts " additional features, then run:"
puts
puts " rake db:create" unless use_mongoid
puts " rake db:migrate" unless use_mongoid
puts " Login to devise with user@domain.com and change_me" if use_devise
puts
puts '======================================================'

