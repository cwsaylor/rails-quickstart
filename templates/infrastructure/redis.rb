require 'redis'

def establish_redis_connection
  if Rails.env.production?
    Redis.new(url: ENV['REDISTOGO_URL'])
  else
    Redis.new(host: 'localhost', port: 6379)
  end
end

$redis = establish_redis_connection
