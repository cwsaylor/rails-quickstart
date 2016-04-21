# Rails Quickstart Template

This template configures a Rails 4.2 app for production level readiness on Heroku.

It includes:

* Twitter Bootstrap or Zurb Foundation
* Simple Form
* Devise
* Heroku
* Slim
* Foreman
* Unicorn
* Redis
* Sidekiq
* Dalli
* Active Admin

## Requirements

* Ruby 2.3.0
* Bundler
* Rails 4.2
* Git

## Usage

    git clone git@github.com:cwsaylor/rails-quickstart.git
    rails new appname -m ./rails-quickstart/base.rb -d postgresql
    cd appname
    foreman start

Navigate to http://0.0.0.0:5000

You will want to secure your sidekiq job admin.
http://0.0.0.0:5000/sidekiq

See here:
https://github.com/mperham/sidekiq/wiki/Monitoring

You may want to clean up the Gemfile as the template process puts gems in an odd order,
then commit your changes.

    git add .
    git commit -m "Initial Rails app"

## Heroku Setup Notes

    heroku create
    heroku addons:create sendgrid:starter
    heroku addons:create redistogo:nano
    heroku addons:create memcachier:dev
    heroku addson:create rollbar
    git push heroku master
    heroku run rake db:migrate
    heroku restart

## Thanks

I would like to thank Daniel Kehoe for the awesome Rails 3 template tutorial:
[http://github.com/fortuity/rails3-mongoid-devise](http://github.com/fortuity/rails3-mongoid-devise)

## Copyright

Copyright (c) 2010 Christopher Saylor. See LICENSE for details.
