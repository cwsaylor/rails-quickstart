# Rails 3 Quickstart Template

This Rails 3 template brings a base rails app up to the bare minimum I use for starting any Rails application. It includes:

* Devise (optional)
* ActiveAdmin (optional)
* Zurb Foundation and Compass
* Heroku - Even if I move to a VPS or other hosting, I always deploy to Heroku in the beginning
* Slim
* RSpec with Capybara and Factory Girl
* Guard
* Pry

## Requirements

* Ruby 1.9.3
* Bundler
* Rails 3
* Git
* `gem install rb-fsevent` on Mac OS X for Guard

## Usage

    rails new appname -m https://raw.github.com/cwsaylor/rails3-quickstart/master/template.rb

## Post Install Notes

* Run `heroku create` to create an application on heroku. Assumes you have an account setup.
* Run `heroku labs:enable user-env-compile`
* Run `guard` to watch for changes to specs
* Create a root route in config/routes.rb: `root :to => "home#index"`

## Thanks

I would like to thank Daniel Kehoe for the awesome Rails 3 template tutorial:
[http://github.com/fortuity/rails3-mongoid-devise](http://github.com/fortuity/rails3-mongoid-devise)

## Copyright

Copyright (c) 2010 Christopher Saylor. See LICENSE for details.
