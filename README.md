# Rails Quickstart Template

This template configures a Rails 8 base app setup with the Solid Trifecta.
It's opinionated in that it sticks to Rails defaults as much as possible.
It supports either PostgreSQL or SQLite3. 

## Gems

* [Mission Control Jobs](https://github.com/rails/mission_control-jobs)

## Requirements

* Rails 8.0
* Ruby 3.4.x or 3.3.x
* Bundler
* Git
* SQLite3 or PostgreSQL
  * For PostgreSQL, I recommend installing it via docker like this. It sets the trusted user to your current username and matches up with the database.yml.
  * `docker run -d --name postgres17 -e POSTGRES_HOST_AUTH_METHOD=trust -e POSTGRES_USER=$USER --restart unless-stopped -p "127.0.0.1:5432:5432" -v postgres-data:/var/lib/postgresql/data postgres:17`
* [RailsPanel](https://github.com/dejan/rails_panel)
* [Mailcatcher](https://mailcatcher.me/)

## Other nifty features

* Generates a pages controller with an index mapped to root_url.
* Generates an admin dashboard controller with an index mapped to admin_root_url.
* Generates Rails 8 authentication and adds tests for session and password reset controller
* Over-rides the default generates_token_for to set a sane password reset token expiration of 4 hours
* Sets up Solid Queue, Cache, and Cable in development
* Installs mission control dashboard and secures it with Rails 8 authentication
* bin/jobs added to bin/dev - comment out and move to a separate terminal if too overwhelming
* Sends email in development to mailcatcher on port 1025

## Usage & Installation

  git clone https://github.com/cwsaylor/rails-quickstart.git 
  rails new APPNAME -d postgresql -c tailwind -m rails-quickstart/template.rb
  cd APPNAME
  bin/dev

Navigate to:
* http://0.0.0.0:3000
* http://0.0.0.0:3000/admin
* http://0.0.0.0:3000/admin/jobs

### Mailcatcher Usage

  gem install mailcatcher
  mailcatcher

Navigate to http://localhost:1080/

## Copyright

Copyright (c) 2010 Christopher Saylor. See LICENSE for details.
