puts "Setting up Haml..."

@root_path = File.expand_path File.join(File.dirname(__FILE__), "..") if @root_path.nil?

gem "haml-rails"

run "bundle install"

run "rm app/views/layouts/application.html.erb"

run "mkdir -p public/stylesheets/sass"

if yes?("Copy over some sass files to get you started: 1kb grid, reset, css3, rails errors?")
  run "cp #{File.join(@root_path, 'sass', '*.*')} public/stylesheets/sass"
else
  touch "public/stylesheets/sass/.gitkeep"
end

append_file ".gitignore" do
  ".sass-cache"
end


create_file "app/views/layouts/application.html.haml" do <<-HAML
!!! 5
%html{ :lang => "en"}
  %head
    %title
      Site Name
    %meta{ :charset => 'utf-8' }
    %meta{ :name => 'description', :content => "" }
    %meta{ :name => 'keywords', :content => "" }
    = stylesheet_link_tag 'application'
    = javascript_include_tag :defaults
    /[if lt IE 9]
      %script{ :src => "http://html5shiv.googlecode.com/svn/trunk/html5.js" } 
    = csrf_meta_tag
  %body
    #header
      %h1
        %a{ :href => '/', :title => "" }
          Site Name  
    - flash.each do |key, value|
      %div{ :class => key } 
        = value
    #content
      =yield
    #footer
      %p
        &copy; #{Time.now.year}
HAML
end

