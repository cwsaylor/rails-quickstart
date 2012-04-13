# Rails 3 Quickstart Template

This Rails 3 template brings a base rails app up to the bare minimum I use for starting any Rails application. It includes:

* Heroku - Even if I move to a VPS or other hosting, I always deploy to Heroku in the beginning
* Haml
* Twitter Bootstrap
* Simpleform configured for Twitter Bootstrap
* RSpec with capybara and factory girl
* Guard
* Pry
* Git

## Requirements

* Bundler
* Rails 3

## Usage

    rails new appname -m https://github.com/cwsaylor/rails3-quickstart/rails3-quickstart/base.rb
  
## Post Install Notes

* Run `rails g bootstrap:layout application fluid` to replace the fixed width application template with a fluid version
* After generating a scaffold, run `rails generate bootstrap:themed CONTROLLER_PATH` to apply bootstap theming to the scaffold
* Run `guard` to watch for changes to specs
* Rails console now launches Pry instead of IRB

## Thanks

I would like to thank Daniel Kehoe for the awesome Rails 3 template tutorial:
[http://github.com/fortuity/rails3-mongoid-devise](http://github.com/fortuity/rails3-mongoid-devise)

## Copyright

Copyright (c) 2010 Christopher Saylor. See LICENSE for details.
