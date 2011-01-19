puts '######################################################'
puts ' Setting up CarrierWave'
puts '######################################################'

gem 'carrierwave'

run 'bundle install'

uploader = ask("Uploader name?")
generate "uploader #{uploader}"

