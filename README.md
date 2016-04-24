# Rails Quickstart Template

This template configures a Rails 5 app for production level readiness on Heroku.
It's highly opinionated about the technologies used.
The heroku services were chosen based on having a free account.

It includes:

* Zurb Foundation 6 (Optional)
* Devise (Optional)
* Active Admin (Optional)
* Font Awesome
* Country select
* Kaminari
* Slim
* Heroku
* Foreman
* dotenv-rails
* Unicorn
* Redis
* Sidekiq
* Dalli
* Rollbar
* Newrelic

## Requirements

* Rails 5.0
* Ruby 2.3.0
* Bundler
* Git
* Redis
* Memcached
* Heroku account

## Other nifty features

* Generates a pages controller with an index mapped to root url
* Controller and action names are added to the body tag as classes for css targetting.
* Replaces application.css with application.scss
* Force explicit javascript requires in application.js by removing require_tree .
* Create a presenter and service folder in app/

## Usage

    git clone git@github.com:cwsaylor/rails-quickstart.git
    rails new appname -m ./rails-quickstart/base.rb -d postgresql
    cd appname
    foreman start

Navigate to http://0.0.0.0:3000

You will want to secure your sidekiq job admin.
http://0.0.0.0:3000/sidekiq

See here:
https://github.com/mperham/sidekiq/wiki/Monitoring

You may want to clean up the Gemfile as the template process puts gems in an odd order,
then commit your changes.

    git add .
    git commit -m "Initial Rails app"

## Heroku Setup Notes

    heroku create
    git push heroku master
    heroku addons:create sendgrid:starter
    heroku addons:create heroku-redis:hobby-dev
    heroku addons:create memcachier:dev
    heroku addson:create rollbar:free
    heroku addons:create newrelic:wayne
    heroku config:set NEW_RELIC_APP_NAME='Your Application Name'
    heroku run rake db:migrate
    heroku restart

## Thanks

I would like to thank Daniel Kehoe for the awesome Rails 3 template tutorial:
[http://github.com/fortuity/rails3-mongoid-devise](http://github.com/fortuity/rails3-mongoid-devise)

## Copyright

Copyright (c) 2010 Christopher Saylor. See LICENSE for details.
