# Rails 3 Quickstart Template

This Rails 3 template brings a base rails app up to the bare minimum I use for starting any Rails application. It includes:

* Postgresql
* Simple Form
* Devise (optional)
* ActiveAdmin (optional)
* Twitter Bootstrap
* Heroku, with configs for Sendgrid and New Relic
* Slim
* RSpec with Capybara and Factory Girl
* Guard
* Pry

## Requirements

* Ruby 1.9.3
* Bundler
* Rails 3
* Git

## Usage

    rails new appname -m https://raw.github.com/cwsaylor/rails3-quickstart/master/template.rb -d postgresql --skip-test-unit

## Post Install Notes

    heroku labs:enable user-env-compile
    heroku create
    git push heroku master
    heroku run rake db:migrate
    heroku restart
    heroku addons:add sendgrid:starter
    heroku addons:add newrelic:standard
    heroku addons:open sendgrid
    heroku addons:open newrelic

  Run `guard` to watch for changes to specs

## Thanks

I would like to thank Daniel Kehoe for the awesome Rails 3 template tutorial:
[http://github.com/fortuity/rails3-mongoid-devise](http://github.com/fortuity/rails3-mongoid-devise)

## Copyright

Copyright (c) 2010 Christopher Saylor. See LICENSE for details.
