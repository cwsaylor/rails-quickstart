# Rails 3 Quickstart Template

This Rails 3 template will walk you through optionally setting up the following:

* carrierwave
* devise
* formtastic
* haml
* jquery
* flutie
* heroku
* mongoid
* rspec
* cucumber with capybara or webrat
* git

## Requirements

I recommend using the excellent [RVM](http://rvm.beginrescueend.com/) to manage your rubies and gems.

* bundler
* rails 3

## Usage

Using remote templates hosted on Github is currently broken. See http://support.github.com/discussions/site/2213-github-https-redirect-breaks-rails-application-generator-templates

    git clone git://github.com/cwsaylor/rails3-quickstart.git
    rails new appname -m rails3-quickstart/templates/wizard.rb

or if you'd rather not use MongoDB, specify a database with the -d option to rails:

    rails new appname -m rails3-quickstart/templates/wizard.rb -d mysql
  
And then answer "n" to "Use Mongoid?"

Since we are using bundler, all commands should be prefixed with bundle exec. A shell alias will assist you with this. Add to your preferred .bashrc/.bash\_profile file.

    alias be="bundle exec"

## Post Install

### Flutie

Add to your layout:

    <%= stylesheet_link_tag :flutie %>

or if you're using Sass:

    @import "flutie";

### Devise

Create a default user:

    rake db:seed

## Thanks

I would like to thank Daniel Kehoe for the awesome Rails 3 template tutorial:
[http://github.com/fortuity/rails3-mongoid-devise](http://github.com/fortuity/rails3-mongoid-devise)

## Copyright

Copyright (c) 2010 Christopher Saylor. See LICENSE for details.
