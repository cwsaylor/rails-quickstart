gem_group :production do
  gem 'rails_12factor'
end

create_file ".slugignore" do
  <<-EOS
/test
/doc
  EOS
end

# TODO Setup skylight instead
# get "https://gist.githubusercontent.com/rwdaigle/2253296/raw/newrelic.yml", "config/newrelic.yml"
