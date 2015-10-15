gem "ember-cli-rails"
gem 'active_model_serializers', '~> 0.8.3'

after_bundle do
  generate "ember-cli:init"
  gsub_file "config/initializers/ember.rb", ":frontend", ":frontend, path: Rails.root.join('frontend').to_s"
  generate "controller ember index --no-helper --no-assets"
  copy_file "templates/ember/application.html.erb", "app/views/layouts/application.html.erb"
  inject_into_file "config/routes.rb", "  get '/*path' => 'ember#index'\n", before: /^end/
  `ember new frontend`
  inside "frontend" do
    `npm install --save-dev ember-cli-rails-addon@0.0.11`
  end
end
