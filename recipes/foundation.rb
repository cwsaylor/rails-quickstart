gem 'foundation-rails', github: 'zurb/foundation-rails'
gem 'foundation-icons-sass-rails'

append_file "app/assets/javascripts/application.js" do
  <<-EOS
//= require foundation
$(document).foundation();
  EOS
end

remove_file "app/views/layouts/application.html.slim"
remove_file "app/assets/stylesheets/application.scss"

copy_file "templates/foundation/application.html.slim", "app/views/layouts/application.html.slim"
copy_file "templates/foundation/application.scss"     , "app/assets/stylesheets/application.scss"
copy_file "templates/foundation/interchange_helper.rb", "app/helpers/interchange_helper.rb"
copy_file "templates/foundation/flash_helper.rb"      , "app/helpers/flash_helper.rb"

after_bundle do
  generate "foundation:install -s --slim"
end
