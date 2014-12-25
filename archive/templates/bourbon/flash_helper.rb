module FlashHelper
  def display_flash
    flash.map do |key, message|
      next if message.blank?
      content_tag(:div, content_tag(:span, message), class: "flash-#{key}")
    end.join.html_safe
  end
end
