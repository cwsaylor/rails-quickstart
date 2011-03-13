puts "Standard cleanup..."

gsub_file "config/application.rb", ":password", ":password, :password_confirmation"

run 'cp config/database.yml config/database.yml.example'

run "rm public/index.html"
run "rm public/images/rails.png"

run 'echo "" > README'

