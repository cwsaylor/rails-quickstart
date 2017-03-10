# Rails Quickstart Template

This template configures a Rails 5 app for production level readiness on Heroku.
It's highly opinionated about the technologies used. If you build SPA's, this is not for you.
This is for those who build The Rails Way.

## Gems

* [Zurb Foundation 6](https://github.com/zurb/foundation-rails)
* [Zurb Foundation for Emails](https://github.com/zurb/foundation-emails)
* [Font Awesome](https://github.com/bokmann/font-awesome-rails)
* [Slim](https://github.com/slim-template/slim)
* [Foreman](https://github.com/ddollar/foreman)
* [dotenv-rails](https://github.com/bkeepers/dotenv)
* [Sidekiq](https://github.com/mperham/sidekiq)
* [Dalli](https://github.com/petergoldstein/dalli)
* [AASM](https://github.com/aasm/aasm)
* [Meta Request](https://github.com/dejan/rails_panel/tree/master/meta_request)
* [Mailcatcher](https://mailcatcher.me/)
* [Rails ERD](https://github.com/voormedia/rails-erd)
* [Annotate](https://github.com/ctran/annotate_models)
* [Meta Tags](https://github.com/kpumuk/meta-tags)

## Requirements

* Rails 5.0
* Ruby 2.3.3
* Bundler
* Git
* Redis
* Memcached
* Heroku account with Memcache, Redis, and Sendgrid addons
* [RailsPanel](https://github.com/dejan/rails_panel)
* [Mailcatcher](https://mailcatcher.me/)
* Graphviz

## Other nifty features

* Generates a pages controller with an index mapped to root_url.

## Usage & Installation

    brew install graphviz redis memcached

    git clone git@github.com:cwsaylor/rails-quickstart.git
    rails new appname -m ./rails-quickstart/base.rb -d postgresql
    cd appname
    rails db:create
    rails db:migrate
    foreman start

Navigate to http://0.0.0.0:3000

You will want to secure your sidekiq job admin.
http://0.0.0.0:3000/sidekiq

See here:
https://github.com/mperham/sidekiq/wiki/Monitoring

### Heroku Setup Notes

    heroku create
    git push heroku master
    heroku addons:create sendgrid:starter
    heroku addons:create heroku-redis:hobby-dev
    heroku addons:create memcachier:dev
    heroku addons:create rollbar:free
    heroku addons:create newrelic:wayne
    heroku run rake db:migrate
    heroku restart

Set the NEW_RELIC_LICENSE_KEY and ROLLBAR_ACCESS_TOKEN environment variables in .env to use in development mode.

    echo "NEW_RELIC_LICENSE_KEY=$(heroku config:get NEW_RELIC_LICENSE_KEY)" >> .env
    echo "ROLLBAR_ACCESS_TOKEN=$(heroku config:get ROLLBAR_ACCESS_TOKEN)" >> .env

### Rails ERD Usage

`bundle exec erd`

### Mailcatcher Usage

`mailcatcher`

Go to http://localhost:1080/

## Other Awesome Gems

* [Devise](https://github.com/plataformatec/devise)
* [Smarter CSV](https://github.com/tilo/smarter_csv)
* [Bundler Audit](https://github.com/rubysec/bundler-audit)
* [Chartkick](https://github.com/ankane/chartkick)
* [Searchkick](https://github.com/ankane/searchkick)
* [Everything by Ankane](https://github.com/ankane)

## Thanks

I would like to thank Daniel Kehoe for the awesome Rails 3 template tutorial:
[http://github.com/fortuity/rails3-mongoid-devise](http://github.com/fortuity/rails3-mongoid-devise)

## Copyright

Copyright (c) 2010 Christopher Saylor. See LICENSE for details.
