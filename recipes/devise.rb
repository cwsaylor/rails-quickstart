# Add for token https://github.com/lynndylanhurley/devise_token_auth
gem 'devise'
gem 'devise-async'

after_bundle do
  generate "devise:install"
  generate "devise user"
  generate "devise:views"

  run "bundle exec rake db:create"

  devise_migration = Dir["db/migrate/*devise_create_users.rb"].first
  gsub_file(devise_migration, "# t", "t")
  gsub_file(devise_migration, "# add_index", "add_index")

  run "bundle exec rake db:migrate"

  create_file "config/initializers/devise_async.rb" do
    <<-EOS
    Devise::Async.backend = :sidekiq
    EOS
  end

  inject_into_file "app/models/user.rb", ":async, :confirmable, ", after: "database_authenticatable, "

  application(nil, env: "production") do
    <<-EOS

    config.to_prepare { Devise::SessionsController.force_ssl }
    config.to_prepare { Devise::RegistrationsController.force_ssl }
    config.to_prepare { Devise::PasswordsController.force_ssl }

    EOS
  end

  append_to_file 'test/test_helper.rb' do
    <<-EOS

  class ActionController::TestCase
    include Devise::TestHelpers
  end

    EOS
  end

  copy_file "templates/devise/users.rb", "test/factories/users.rb"
  copy_file "templates/devise/users_preview.rb", "test/mailers/previews/users_preview.rb"
end
