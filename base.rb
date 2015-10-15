def source_paths
  [File.expand_path(File.dirname(__FILE__))]
end

@activeadmin = yes?("Install Activeadmin?")
@bootstrap   = yes?("Install Bootstrap?")
@devise      = yes?("Install Devise?")
# @ember       = yes?("Install Ember")
@foundation  = yes?("Install Foundation?")
@sendgrid    = yes?("Send email with Sendgrid?")

apply "recipes/infrastructure.rb"
apply "recipes/frontend.rb"

apply "recipes/activeadmin.rb" if @activeadmin
apply "recipes/bootstrap.rb" if @boostrap
apply "recipes/devise.rb" if @devise
# apply "recipes/ember.rb" if @ember
apply "recipes/foundation.rb" if @foundation
apply "recipes/heroku.rb"
apply "recipes/memcached.rb"
# apply "recipes/resque.rb"
apply "recipes/sendgrid.rb" if @sendgrid
apply "recipes/sidekiq.rb"
apply "recipes/testing.rb"

run "bundle install"
run "bundle exec rake db:create"
run "bundle exec spring binstub --all"

git :init
# git :add => "."
# git :commit => "-m 'Setup base Rails app.'"
