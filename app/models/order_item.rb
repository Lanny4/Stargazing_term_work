class OrderItem < ApplicationRecord
  belongs_to :order
  belongs_to :product
  validates :product_name, presence: true
  validates :quantity, numericality: { only_integer: true, greater_than: 0 }
  validates :price_cents, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  def total_cents
    quantity * price_cents
  end
end
