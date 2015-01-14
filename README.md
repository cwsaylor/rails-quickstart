# Rails Quickstart Template

This template configures a Rails 4.2 app for production level readiness on Heroku.

It includes:

* Bootstrap Form Helpers
* Devise
* Twitter Bootstrap
* Bootstrap Form
* Bootswatch
* Styleguide
* Heroku, with configs for Mandrill, Redistogo, Memcachier and New Relic
* Slim
* Foreman
* Unicorn
* Resque
* Dalli
* Active Admin
* Holder.js
* Pow config for reading .env

## Requirements

* Ruby 2.2.0
* Bundler
* Rails 4.2
* Git
* Pow

## Rails 4 Usage

    git clone git@github.com:cwsaylor/rails-quickstart.git
    rails new appname -m ./rails-quickstart/master/rails41.rb -d postgresql
    cd appname
    foreman start

Navigate to http://0.0.0.0:5000

## Heroku Setup Notes

    heroku create
    heroku addons:add mandrill:starter
    heroku addons:add newrelic:stark
    heroku addons:add redistogo
    heroku addons:add memcachier:dev
    heroku config:set NEW_RELIC_APP_NAME=APP_NAME
    git push heroku master
    heroku run rake db:migrate
    heroku restart
    heroku addons:open newrelic

## Thanks

I would like to thank Daniel Kehoe for the awesome Rails 3 template tutorial:
[http://github.com/fortuity/rails3-mongoid-devise](http://github.com/fortuity/rails3-mongoid-devise)

## Copyright

Copyright (c) 2010 Christopher Saylor. See LICENSE for details.
