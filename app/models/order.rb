class Order < ApplicationRecord
  class CheckoutError < StandardError; end
  SHIPPING = { "pickup" => ["Самовивіз", 0], "nova_poshta" => ["Нова пошта (демо)", 6500],
               "ukrposhta" => ["Укрпошта (демо)", 4500] }.freeze
  STATUS_TRANSITIONS = { "placed" => %w[shipped canceled], "paid" => %w[shipped canceled], "shipped" => [], "canceled" => [] }.freeze
  PAYMENTS = { "cod" => "Післяплата", "demo_card" => "Демо-оплата карткою" }.freeze

  belongs_to :user
  has_many :order_items, dependent: :destroy
  validates :customer_name, presence: true, length: { minimum: 2, maximum: 80 }
  validates :phone, format: { with: /\A\+?[0-9 ()-]{9,20}\z/ }
  validates :city, presence: true, length: { maximum: 120 }
  validates :address, presence: true, length: { maximum: 250 }
  validates :shipping_method, inclusion: { in: SHIPPING.keys }
  validates :payment_method, inclusion: { in: PAYMENTS.keys }
  validates :status, inclusion: { in: %w[placed paid shipped canceled] }
  validates :subtotal_cents, :shipping_cents, :total_cents,
            numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  # Навчальна панель: одна зміна статусу за транзакцію; при скасуванні
  # повертаємо залишки тільки один раз.
  def change_status_by_admin!(new_status)
    transaction do
      lock!
      unless STATUS_TRANSITIONS.fetch(status, []).include?(new_status)
        raise CheckoutError, "Недопустимий перехід статусу замовлення"
      end
      if new_status == "canceled"
        order_items.order(:product_id).each do |item|
          product = Product.lock.find(item.product_id)
          product.update!(stock: product.stock + item.quantity)
        end
      end
      update!(status: new_status)
    end
  end

  def self.checkout!(user:, cart:, attributes:)
    raise CheckoutError, "Кошик порожній" if cart.blank?

    transaction do
      order = user.orders.build(attributes.merge(status: "placed"))
      # Не довіряємо цінам із браузера. Фіксуємо ціни й залишки під блокуванням.
      lines = cart.sort_by { |product_id, _| product_id.to_i }.map do |product_id, quantity|
        product = Product.lock.find_by(id: product_id.to_i, active: true)
        raise CheckoutError, "Один із товарів більше недоступний" unless product
        quantity = Integer(quantity)
        raise CheckoutError, "Некоректна кількість товару" unless quantity.between?(1, 99)
        raise CheckoutError, "Недостатньо товару «#{product.name}»" if product.stock < quantity
        [product, quantity]
      end
      order.subtotal_cents = lines.sum { |product, quantity| product.price_cents * quantity }
      order.shipping_cents = SHIPPING.fetch(order.shipping_method, [nil, 0]).last
      order.total_cents = order.subtotal_cents + order.shipping_cents
      order.save!
      lines.each do |product, quantity|
        order.order_items.create!(product: product, product_name: product.name,
                                 quantity: quantity, price_cents: product.price_cents)
        product.update!(stock: product.stock - quantity)
      end
      order
    end
  end
end
