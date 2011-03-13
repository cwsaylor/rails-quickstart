@root_path     = File.expand_path File.join(File.dirname(__FILE__), "..") 
@template_path = File.expand_path File.join(@root_path, "templates") 

apply "#{@template_path}/cleanup.rb"
apply "#{@template_path}/mongoid.rb"     if yes?("Use Mongoid?")
apply "#{@template_path}/jquery.rb"      if yes?("Use jQuery?")
apply "#{@template_path}/haml.rb"        if yes?("Use Haml?")
apply "#{@template_path}/carrierwave.rb" if yes?("Use CarrierWave?")
apply "#{@template_path}/devise.rb"      if yes?("Use Devise?")
apply "#{@template_path}/rspec.rb"       if yes?("Use Rspec?")
apply "#{@template_path}/cucumber.rb"    if yes?("Use Cucumber?")
apply "#{@template_path}/formtastic.rb"  if yes?("Use Formtastic?")
apply "#{@template_path}/flutie.rb"      if yes?("Use Flutie?")
apply "#{@template_path}/heroku.rb"      if yes?("Use Heroku?")
apply "#{@template_path}/git.rb"

