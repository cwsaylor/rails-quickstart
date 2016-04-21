gem 'autoprefixer-rails'
gem 'bootstrap-sass'

remove_file "app/views/layouts/application.html.slim"
remove_file "app/assets/stylesheets/application.scss"

copy_file "templates/bootstrap/application.html.slim", "app/views/layouts/application.html.slim"
copy_file "templates/bootstrap/application.scss"     , "app/assets/stylesheets/application.scss"
copy_file "templates/bootstrap/flash_helper.rb"      , "app/helpers/flash_helper.rb"

append_file "app/assets/javascripts/application.js" do
  "//= require bootstrap-sprockets"
end
