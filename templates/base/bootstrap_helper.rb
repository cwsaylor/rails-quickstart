module BootstrapHelper
  ALERT_TYPES = {
    success: :success,
    notice:  :success,
    info:    :info,
    warning: :warning,
    danger:  :danger,
    alert:   :danger
  }

  def bootstrap_flash
    flash_messages = []
    flash.each do |key, message|
      # Skip empty messages, e.g. for devise messages set to nothing in a locale file.
      next if message.blank?
      type = ALERT_TYPES.fetch(key, :info)

      Array(message).each do |msg|
        text = content_tag(:div,
                           content_tag(:button,
                                       content_tag(:span, "&times;".html_safe, "aria-hidden" => "true") + content_tag(:span, "Close", class: "sr-only"),
                                       class: "close", data: { dismiss: "alert" }) + msg,
                           class: "alert alert-#{type} alert-dismissible", role: "alert")
        flash_messages << text if message
      end
    end
    flash_messages.join("\n").html_safe
  end
end
