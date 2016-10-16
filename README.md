# Rails Quickstart Template

This template configures a Rails 5 app for production level readiness on Heroku.
It's highly opinionated about the technologies used. If you build SPA's, this is not for you.
This is for those who build The Rails Way.

It includes:

* Zurb Foundation 6
* Font Awesome
* Slim
* Foreman
* dotenv-rails
* Sidekiq
* Dalli
* Sendgrid
* AASM
* Meta Request for use with [RailsPanel](https://github.com/dejan/rails_panel)
* Mailcatcher

## Requirements

* Rails 5.0
* Ruby 2.3.1
* Bundler
* Git
* Redis
* Memcached
* Heroku account
* [Mailcatcher](https://mailcatcher.me/)

## Other nifty features

* Generates a pages controller with an index mapped to root url.

## Usage

    git clone git@github.com:cwsaylor/rails-quickstart.git
    rails new appname -m ./rails-quickstart/base.rb -d postgresql
    cd appname
    rails db:create
    rails db:migrate
    foreman start

Navigate to http://0.0.0.0:3000

You will want to secure your sidekiq job admin.
http://0.0.0.0:3000/sidekiq

See here:
https://github.com/mperham/sidekiq/wiki/Monitoring

## Heroku Setup Notes

    heroku create
    git push heroku master
    heroku addons:create sendgrid:starter
    heroku addons:create heroku-redis:hobby-dev
    heroku addons:create memcachier:dev
    heroku addons:create rollbar:free
    heroku addons:create newrelic:wayne
    heroku run rake db:migrate
    heroku restart

Set the NEW_RELIC_LICENSE_KEY and ROLLBAR_ACCESS_TOKEN environment variables in .env to use in development mode.

    echo "NEW_RELIC_LICENSE_KEY=$(heroku config:get NEW_RELIC_LICENSE_KEY)" >> .env
    echo "ROLLBAR_ACCESS_TOKEN=$(heroku config:get ROLLBAR_ACCESS_TOKEN)" >> .env

## Thanks

I would like to thank Daniel Kehoe for the awesome Rails 3 template tutorial:
[http://github.com/fortuity/rails3-mongoid-devise](http://github.com/fortuity/rails3-mongoid-devise)

## Copyright

Copyright (c) 2010 Christopher Saylor. See LICENSE for details.
