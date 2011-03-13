run 'rm public/index.html'
run 'rm public/images/rails.png'
run 'echo "" > README'
run 'cp config/database.yml config/database.yml.example'

gsub_file 'config/application.rb', ':password', ':password, :password_confirmation'

append_file ".gitignore", ".DS_Store\n"
append_file ".gitignore", "config/database.yml\n"

create_file 'public/stylesheets/application.css' do <<-CSS
/* http://meyerweb.com/eric/tools/css/reset/ 
   v2.0 | 20110126
   License: none (public domain)
*/

html, body, div, span, applet, object, iframe,
h1, h2, h3, h4, h5, h6, p, blockquote, pre,
a, abbr, acronym, address, big, cite, code,
del, dfn, em, img, ins, kbd, q, s, samp,
small, strike, strong, sub, sup, tt, var,
b, u, i, center,
dl, dt, dd, ol, ul, li,
fieldset, form, label, legend,
table, caption, tbody, tfoot, thead, tr, th, td,
article, aside, canvas, details, embed, 
figure, figcaption, footer, header, hgroup, 
menu, nav, output, ruby, section, summary,
time, mark, audio, video {
	margin: 0;
	padding: 0;
	border: 0;
	font-size: 100%;
	font: inherit;
	vertical-align: baseline;
}
/* HTML5 display-role reset for older browsers */
article, aside, details, figcaption, figure, 
footer, header, hgroup, menu, nav, section {
	display: block;
}
body {
	line-height: 1;
}
ol, ul {
	list-style: none;
}
blockquote, q {
	quotes: none;
}
blockquote:before, blockquote:after,
q:before, q:after {
	content: '';
	content: none;
}
table {
	border-collapse: collapse;
	border-spacing: 0;
}
/* ************ */
/* Rails Errors */
/* ************ */

.field_with_errors {
  padding: 2px;
  background-color: red;
  display: table;
}

#error_explanation {
  width: 450px;
  border: 2px solid red;
  padding: 7px;
  padding-bottom: 0;
  margin-bottom: 20px;
  background-color: #f0f0f0;
}

#error_explanation h2 {
  text-align: left;
  font-weight: bold;
  padding: 5px 5px 5px 15px;
  font-size: 12px;
  margin: -7px;
  margin-bottom: 0px;
  background-color: #c00;
  color: #fff;
}

#error_explanation ul li {
  font-size: 12px;
  list-style: square;
}

/* ************************************************************** */
/*  The 1Kb Grid 12 columns, 60 pixels each, with 20 pixel gutter */
/* ************************************************************** */

.grid_1 { width:60px; }
.grid_2 { width:140px; }
.grid_3 { width:220px; }
.grid_4 { width:300px; }
.grid_5 { width:380px; }
.grid_6 { width:460px; }
.grid_7 { width:540px; }
.grid_8 { width:620px; }
.grid_9 { width:700px; }
.grid_10 { width:780px; }
.grid_11 { width:860px; }
.grid_12 { width:940px; }

.column {
	margin: 0 10px;
	overflow: hidden;
	float: left;
	display: inline;
}
.row {
	width: 960px;
	margin: 0 auto;
	overflow: hidden;
}
.row .row {
	margin: 0 -10px;
	width: auto;
	display: inline-block;
}
CSS
end

create_file 'app/views/layouts/application.html.haml' do <<-HAML
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
    = csrf_meta_tag
  %body
    #header
      .row
        .column.grid_12
          %h1
            %a{ :href => '/', :title => "" }
              Site Name
    - flash.each do |key, value|
      .row{ :class => key } 
        .column.grid_12
          = value
    #content
      .row
        .column.grid_12
          =yield
    #footer
      .row
        .column.grid_12
          %hr
          %p
            &copy; #{Time.now.year} Site Name
HAML
end

git :init
git :add => '.'
git :commit => "-m 'Initial commit of our rails app with jquery, rspec, cucumber and haml.'"
