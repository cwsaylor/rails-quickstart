ActiveAdmin.register_page "Mailers" do
  sidebar :mailers do
    ul do
      li do
        link_to "Password Reset", "/rails/mailers/devise_mailer/reset_password_instructions", target: "preview"
      end
      li do
        link_to "Confirmation", "/rails/mailers/devise_mailer/confirmation_instructions", target: "preview"
      end
    end
  end

  content do
    content_tag :iframe, nil, name: "preview", width: "75%", height: "550", seamless: "seamless"
  end
end

