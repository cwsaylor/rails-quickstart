gem 'country_select'
gem 'font-awesome-rails'
# gem 'jquery-turbolinks'
gem 'kaminari'
gem 'slim-rails'

remove_file "app/views/layouts/application.html.erb"
remove_file "app/assets/stylesheets/application.css"

copy_file "templates/frontend/application.html.slim", "app/views/layouts/application.html.slim"
copy_file "templates/frontend/application.scss", "app/assets/stylesheets/application.scss"

gsub_file "app/assets/javascripts/application.js", "//= require_tree .\n", ""
# inject_into_file "app/assets/javascripts/application.js", "//= require jquery.turbolinks\n", after: "//= require jquery\n"

after_bundle do
  generate "controller pages index --no-helper --no-assets"
  route "root to: 'pages#index'"
end
