gem 'activeadmin', github: 'activeadmin'
gem 'devise'

application do
  "config.app_generators.scaffold_controller :scaffold_controller"
end

after_bundle do
  generate "active_admin:install"
end

if @devise
  copy_file "templates/activeadmin/devise_mailers.rb", "app/admin/devise_mailers.rb"
end
