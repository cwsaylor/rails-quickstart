# Rails Quickstart Template

This Rails template brings a base rails app up to the bare minimum I use for starting any Rails application. It includes:

* Postgresql
* Simple Form
* Devise (optional)
* ActiveAdmin (optional)
* Delayed Job w/ Hirefire.io support (optional)
* Zurb Foundation (Rails 4)
* Twitter Bootstrap (Rails 3)
* Heroku, with configs for Sendgrid and New Relic
* Slim
* RSpec with Capybara and Factory Girl
* Guard
* Pry
* Remote Pry debugger
* Foreman

## Requirements

* Ruby 1.9.3
* Bundler
* Rails 3
* Git

## Rails 3 Usage

    rails new appname -m https://raw.github.com/cwsaylor/rails-quickstart/master/rails3.rb -d postgresql --skip-test-unit

## Rails 4 Usage

    rails new appname -m https://raw.github.com/cwsaylor/rails-quickstart/master/rails4.rb -d postgresql --skip-test-unit

## Post Install Notes

Login to /admin with admin@example.com and password. You'll want to change this.

    heroku create
    git push heroku master
    heroku run rake db:migrate
    heroku restart
    heroku addons:add zerigo_dns:basic
    heroku addons:add sendgrid:starter
    heroku addons:add newrelic:standard
    heroku config:set NEW_RELIC_APP_NAME=appname
    heroku addons:open sendgrid
    heroku addons:open newrelic
    heroku addons:open zerigo_dns

Delete A record entries and setup a redirect form domain.com to www.domain.com
Change CNAME to appname.herokuapp.com

If you setup delayed job, add some workers

    heroku ps:scale worker=1

Setup an account at http://hirefire.io and add your application.

  Run `guard` to watch for changes to specs
  Run `foreman` to start your server and workers

See https://github.com/nixme/pry-debugger for remote pry debugging

## Thanks

I would like to thank Daniel Kehoe for the awesome Rails 3 template tutorial:
[http://github.com/fortuity/rails3-mongoid-devise](http://github.com/fortuity/rails3-mongoid-devise)

## Copyright

Copyright (c) 2010 Christopher Saylor. See LICENSE for details.
