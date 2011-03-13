puts "Setting up jQuery..."

gem "jquery-rails"

run "bundle install"

run "rm public/javascripts/rails.js"

jquery  = ask("jQuery version?")
generate "jquery:install --version #{jquery}"
