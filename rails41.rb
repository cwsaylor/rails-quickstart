gem_group :test, :development do
  gem 'byebug'
end

gem_group :production do
  gem 'rails_12factor'
end

gem 'slim-rails'
gem 'bootstrap-sass'

inject_into_file "Gemfile", :after => "source 'https://rubygems.org'\n" do
  "ruby '2.1.1'\n"
end

gsub_file "Gemfile", "gem 'turbolinks'", "#gem 'turbolinks'"
gsub_file "app/assets/javascripts/application.js", "//= require turbolinks\n", ""

run "bundle install"
run "rake db:create"
run 'rake db:migrate'

remove_file 'app/views/layouts/application.html.erb'
remove_file 'app/assets/stylesheets/application.css'

run "curl https://gist.githubusercontent.com/cwsaylor/11094449/raw/application.html.slim > app/views/layouts/application.html.slim"

create_file 'app/assets/stylesheets/application.css.scss' do
  <<-EOS
@import "bootstrap";
@import "bootstrap/theme";
  EOS
end

append_file '.gitignore' do
  <<-EOS
.DS_Store
  EOS
end

create_file '.slugignore' do
  <<-EOS
/test
/doc
  EOS
end

generate "controller pages index --no-helper --no-assets --no-test-framework"

inject_into_file 'config/routes.rb', :after => "routes.draw do\n" do
  "  root :to => 'pages#index'\n"
end

git :init
git :add => "."
# git :commit => "-m 'Setup base Rails app for Heroku with Slim and Twitter Bootstrap.'"

puts "################################################################################"
puts "heroku create"
puts "git push heroku master"
puts "heroku run rake db:migrate"
puts "heroku restart"
puts "################################################################################"

