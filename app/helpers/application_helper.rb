module ApplicationHelper
  def money(cents)
    number_to_currency(cents.to_i / 100.0, unit: "₴", separator: ",", delimiter: " ", format: "%n %u")
  end

  def display_status(status)
    { "placed" => "Оформлено", "paid" => "Оплачено (демо)",
      "shipped" => "Відправлено", "canceled" => "Скасовано" }.fetch(status, status)
  end

  def errors_for(record)
    return unless record&.errors&.any?
    content_tag(:div, class: "form-errors", role: "alert") do
      safe_join([content_tag(:strong, "Виправте помилки:"),
                 content_tag(:ul, safe_join(record.errors.full_messages.map { |m| content_tag(:li, m) }))])
    end
  end
end
