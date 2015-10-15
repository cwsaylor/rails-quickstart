gem 'resque-scheduler'
gem 'resque'

inject_into_file "config/routes.rb", after: "ActiveAdmin::Devise\.config\n" do
  <<-EOS
  authenticate :admin_user do
    mount Resque::Server.new, :at => "/jobs"
  end
  EOS
end

append_file "Procfile" do
  <<-EOS
resque: env INTERVAL=0.1 QUEUES=* bundle exec rake resque:work
  EOS
end

copy_file "templates/resque/active_job.rb", "config/initializers/active_job.rb"
copy_file "templates/resque/resque.rb"    , "config/initializers/resque.rb"
copy_file "templates/resque/resque.rake"  , "lib/tasks/resque.rake"
