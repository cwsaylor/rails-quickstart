#############################################

heroku create
heroku addons:add newrelic:stark
heroku config:set NEW_RELIC_APP_NAME=APP_NAME
git push heroku master
heroku run rake db:migrate
heroku restart
heroku addons:open newrelic

#############################################
