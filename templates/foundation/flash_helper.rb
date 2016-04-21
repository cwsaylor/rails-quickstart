module FlashHelper
  DEFAULT_KEY_MATCHING = {
    # Rails
    :notice    => :success,
    :error     => :alert,
    # Foundation
    :primary   => :primary,
    :secondary => :secondary,
    :success   => :success,
    :warning   => :warning,
    :alert     => :alert
  }
  def display_flash(key_matching = {}, size = "")
    key_matching = DEFAULT_KEY_MATCHING.merge(key_matching)

    flash.inject "" do |message, (key, value)|
      # TODO: Set a motion ui class on closable
      message += content_tag :div, data: { closable: "" }, class: ["callout", size, key_matching[key.to_sym] || :primary] do
        (value + close_button).html_safe
      end
    end.html_safe
  end

  def close_button
    button_tag(type: "button", class: "close-button", aria: { label: "Dismiss alert" }, data: { close: "" }) do
      content_tag(:span, "&times;".html_safe, aria: { hidde: "true" })
    end
  end
end
