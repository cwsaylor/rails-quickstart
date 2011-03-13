puts "Setting up CarrierWave..."

gem "carrierwave"

run "bundle install"

uploader = ask("Uploader name i.e. Picture?")

generate "uploader #{uploader}"

