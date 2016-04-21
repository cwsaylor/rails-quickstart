gem 'sidekiq'
gem 'sinatra', require: nil

append_to_file 'Procfile', 'worker: bundle exec sidekiq'

create_file 'config/initializers/active_job.rb' do
  <<-EOS
  if Rails.env.test?
    ActiveJob::Base.queue_adapter = :inline
  else
    ActiveJob::Base.queue_adapter = :sidekiq
  end
  EOS
end


prepend_to_file 'config/routes.rb', "require 'sidekiq/web'\n"

inject_into_file "config/routes.rb", after: "Rails.application.routes.draw do\n" do
  <<-EOS
  mount Sidekiq::Web => '/sidekiq'
  EOS
end
