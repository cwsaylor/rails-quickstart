# Rails Quickstart Template

This Rails template brings a base rails app up to the bare minimum I use for starting any Rails application and deploying on Heroku.

It includes:

* Bootstrap Form Helpers
* Devise
* Twitter Bootstrap
* Heroku, with configs for Sendgrid and New Relic
* Slim
* Foreman
* Unicorn

## Requirements

* Ruby 2.1.3
* Bundler
* Rails 4.1
* Git

## Rails 4 Usage

    git clone git@github.com:cwsaylor/rails-quickstart.git
    rails new appname -m ./rails-quickstart/master/rails41-bootstrap.rb -d postgresql
    cd appname
    rake db:migrate
    foreman start

## Post Install Notes

Edit the Devise migration and model and uncomment desired features.

## Thanks

I would like to thank Daniel Kehoe for the awesome Rails 3 template tutorial:
[http://github.com/fortuity/rails3-mongoid-devise](http://github.com/fortuity/rails3-mongoid-devise)

## Copyright

Copyright (c) 2010 Christopher Saylor. See LICENSE for details.
