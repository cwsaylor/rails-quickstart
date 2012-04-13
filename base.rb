run 'cp config/database.yml config/database.yml.example'
remove_file 'public/index.html'
remove_file 'public/images/rails.png'
remove_file 'app/views/layouts/application.html.erb'
run 'echo "" > README'

gem 'haml-rails'
gem 'twitter-bootstrap-rails', :git => 'git://github.com/seyhunak/twitter-bootstrap-rails.git'
gem 'simple_form', :git => 'git://github.com/plataformatec/simple_form.git'
gem "heroku"
gem 'pry-rails', :group => :development
gem 'rspec-rails', :group => [:test, :development]

gem_group :test do
  gem "factory_girl_rails"
  gem "capybara"
  gem "guard-rspec"
end

run "bundle install"

generate "bootstrap:install"
generate "bootstrap:layout"
generate "simple_form:install --bootstrap"
generate "rspec:install"

inject_into_file 'spec/spec_helper.rb', :after => "require 'rspec/autorun'\n" do
  "require 'capybara/rspec'\n"
end

run 'bundle exec guard init rspec'

append_file '.gitignore' do
  '.DS_Store'
  'config/database.yml'
end

git :init
git :add => "."
git :commit => "-m 'Initial commit.'"

puts "-----------------------------------------------"
puts "You should run `gem install rb-fsevent`"
puts "-----------------------------------------------"
