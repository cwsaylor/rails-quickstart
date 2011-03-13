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
* git

## Usage

Using remote templates hosted on Github is currently broken. See http://support.github.com/discussions/site/2213-github-https-redirect-breaks-rails-application-generator-templates

    git clone git://github.com/cwsaylor/rails3-quickstart.git
    rails new appname -m rails3-quickstart/templates/wizard.rb

or if you'd rather not use MongoDB, specify a database with the -d option to rails:

    rails new appname -m rails3-quickstart/templates/wizard.rb -d mysql
  
And then answer "n" to "Use Mongoid?"

## Thanks

I would like to thank Daniel Kehoe for the awesome Rails 3 template tutorial:
[http://github.com/fortuity/rails3-mongoid-devise](http://github.com/fortuity/rails3-mongoid-devise)

## Copyright

Copyright (c) 2010 Christopher Saylor. See LICENSE for details.
