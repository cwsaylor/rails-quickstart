@template_path = File.expand_path(File.join(File.dirname(__FILE__), ".."))

def tp_copy(from_file, to_file)
  copy_file "#{@template_path}/#{from_file}", "#{to_file}"
end

apply "#{@template_path}/templates/cleanup.rb"
apply "#{@template_path}/templates/mongoid.rb"     if yes?("Use Mongoid?")
apply "#{@template_path}/templates/jquery.rb"      if yes?("Use jQuery?")
apply "#{@template_path}/templates/haml.rb"        if yes?("Use Haml?")
apply "#{@template_path}/templates/carrierwave.rb" if yes?("Use CarrierWave?")
apply "#{@template_path}/templates/devise.rb"      if yes?("Use Devise?")
apply "#{@template_path}/templates/rspec.rb"       if yes?("Use Rspec & Cucumber?")
apply "#{@template_path}/templates/formtastic.rb"  if yes?("Setup Formtastic?")
apply "#{@template_path}/templates/heroku.rb"      if yes?("Set up Heroku?")
apply "#{@template_path}/templates/git.rb"

