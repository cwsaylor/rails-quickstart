def source_paths
  super + [File.expand_path(File.dirname(__FILE__) + "/templates")]
end

app_name = Pathname.new(`pwd`).split.last.to_s.strip

if yes?("Customize defaults?")
  solid_trifecta  = yes?("Setup the Solid Trifecta in development")
  mission_control = yes?("Setup Mission Control Jobs")
  rails_panel     = yes?("Setup Rails Panel")
  auth            = yes?("Setup Rails 8 authentication")
  tailwind        = yes?("Use Tailwind application layout?")
  admin           = yes?("Setup admin dashboard?")
  homepage        = yes?("Setup pages controller and homepage?")
  mailcatcher     = yes?("Setup mailcatcher")
end

# Ignore MacOS files
append_file ".gitignore" do
  <<-EOS
.DS_Store
  EOS
end

if mission_control
  gem "mission_control-jobs"
end

if rails_panel
  inject_into_file "Gemfile", after: "group :development do\n" do
  <<-EOS
    gem "meta_request"
  EOS
  end
end

run "bundle install"
git :init
git add: ".", commit: %(-m "Setup Rails #{Rails::VERSION::STRING} app with Rails Quickstart")

after_bundle do
  # Setup database file
  db_file = File.read("config/database.yml")

  if db_file.include?('postgresql')
    db = "postgresql"
  elsif db_file.include?('sqlite3')
    db = "sqlite3"
  end

  if ! db.nil? & mission_control
    template "database_#{db}.yml.tt", "config/database.yml", force: true
  end

  rails_command "db:create"
  rails_command "db:migrate"

  git add: ".", commit: %(-m "Setup #{db.nil? ? 'database' : db}")

  # Generate authentication with a seed user and test helper
  if auth
    generate "authentication"
    gsub_file "test/fixtures/users.yml", "one:", "alice:"
    gsub_file "test/fixtures/users.yml", "two:", "bob:"
    append_file "db/seeds.rb", %(User.create_with(password: "Test123", password_confirmation: "Test123").find_or_create_by(email_address: "user@host.com"))
    template "session_helper.rb", "test/helpers/session_helper.rb"
    template "passwords_controller_test.rb", "test/controllers/passwords_controller_test.rb"
    template "sessions_controller_test.rb", "test/controllers/sessions_controller_test.rb"

    # Over-ride password reset token expiration time to somethign sane
    inject_into_file "app/models/user.rb", before: /^end$/ do
    <<-EOS

    generates_token_for :password_reset, expires_in: 4.hours do
      # Last 10 characters of password salt, which changes when password is updated:
      password_salt&.last(10)
    end
    EOS
    end

    rails_command "db:migrate"
    rails_command "db:seed"

    git add: ".", commit: %(-m "Generate Rails 8 authentication with a login seed and tests")
  end

  # Style the application layout
  if tailwind
    gsub_file "app/views/layouts/application.html.erb", /\s*<body>[\s\S]*?<\/body>\s*/i do
    <<-EOS

    <body class="min-h-screen bg-white font-sans flex flex-col">
      <header class="bg-white shadow">
        <div class="max-w-7xl mx-auto py-4 px-4 sm:px-6 lg:px-8">
          <div class="flex justify-between items-center">
            <h1 class="text-3xl font-bold text-gray-900"><%= link_to #{app_name.capitalize}, root_path %></h1>
            <% if authenticated? %>
              <%= button_to "Logout", session_path, method: :delete, class: "px-4 py-2 bg-blue-600 text-white rounded-md hover:bg-blue-700 transition-colors" %>
            <% else %>
              <%= link_to "Login", new_session_path, class: "px-4 py-2 bg-blue-600 text-white rounded-md hover:bg-blue-700 transition-colors" %>
            <% end %>
          </div>
        </div>
      </header>

      <main class="flex-grow">
        <div class="max-w-7xl mx-auto py-4 px-4 sm:px-6 lg:px-8">
          <%= yield %>
        </div>
      </main>

      <footer class="bg-gray-50">
        <div class="max-w-7xl mx-auto py-4 px-4 sm:px-6 lg:px-8">
          <p class="text-center text-gray-500 text-sm">
            &copy; <%= Time.current.year %> #{app_name.capitalize}. All rights reserved.
          </p>
        </div>
      </footer>
    </body>
    EOS
    end

    git add: ".", commit: %(-m "Style the application layout a bit better with Tailwind")
  end

  # Generate a home page
  if homepage
    generate "controller", "pages", "index", "--no-helper", "--no-assets"
    gsub_file "app/controllers/pages_controller.rb", "ApplicationController\n", %(ApplicationController\n  allow_unauthenticated_access\n)
    gsub_file "config/routes.rb", %(get "pages/index"), %(root to: "pages#index")
    template "pages_controller_test.rb", "test/controllers/pages_controller_test.rb", force: true

    git add: ".", commit: %(-m "Generate a home page and root route with tests")
  end

  # Generate an admin dashboard
  if admin
    generate "controller", "admin/dashboard", "index"
    gsub_file "config/routes.rb", %(get "dashboard/index"), %(root to: "dashboard#index")
    gsub_file "app/controllers/admin/dashboard_controller.rb", "ApplicationController", %(Admin::BaseController)
    template "admin_base_controller.rb", "app/controllers/admin/base_controller.rb"
    template "dashboard_controller_test.rb", "test/controllers/admin/dashboard_controller_test.rb", force: true

    git add: ".", commit: %(-m "Generate an admin dashboard with tests")
  end

  if solid_trifecta
    # Configure Solid Queue in development
    environment(nil, env: "development") do
      <<-EOS
      # Replace the default in-process and non-durable queuing backend for Active Job.
      config.active_job.queue_adapter = :solid_queue
      config.solid_queue.connects_to = { database: { writing: :queue } }

      EOS
    end

    append_file "Procfile.dev", "jobs: bin/jobs\n"

    git add: ".", commit: %(-m "Setup Solid Queue in development")

    # Configure Solid Cache in development
    gsub_file "config/cache.yml", "development:\n", %(development:\n  database: cache\n)
    gsub_file "config/environments/development.rb", ":memory_store", ":solid_cache_store"

    git add: ".", commit: %(-m "Setup Solid Cache in development")

    # Configure Solid Cable in development
    inject_into_file "config/cable.yml", after: "adapter: async\n" do
    <<-EOS
    connects_to:
      database:
        writing: cable
    polling_interval: 0.1.seconds
    message_retention: 1.day    
    EOS
    end

    gsub_file "config/cable.yml", "adapter: async", "adapter: solid_cable"

    git add: ".", commit: %(-m "Setup Solid Cable in development")
  end

  # Configure Mission Control
  if mission_control
    environment(nil, env: "development") do
      <<-EOS
      # Configure Mission Control
      config.mission_control.jobs.http_basic_auth_enabled = false
      config.mission_control.jobs.base_controller_class = "Admin::BaseController"

      EOS
    end

    route %(mount MissionControl::Jobs::Engine, at: "/admin/jobs")

    git add: ".", commit: %(-m "Setup Mission Control")
  end

  # Configure mailcatcher
  if mailcatcher
    environment(nil, env: "development") do
      <<-EOS
      config.action_mailer.delivery_method = :smtp
      config.action_mailer.smtp_settings = { :address => '127.0.0.1', :port => 1025 }

      EOS
    end

    git add: ".", commit: %(-m "Configure mailcatcher")
  end
end
