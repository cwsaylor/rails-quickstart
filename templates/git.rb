puts "Setting up git..."

append_file '.gitignore' do
  '.DS_Store'
  'config/database.yml'
  '.rvmrc'
end

git :init
git :add => "."
git :commit => "-m 'Initial commit of a base rails app.'"

