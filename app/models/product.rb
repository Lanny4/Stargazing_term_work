require "json"

class Product < ApplicationRecord
  PHOTO_INFO = JSON.parse(Rails.root.join("config/product_photos.json").read).freeze
  IMAGES = (PHOTO_INFO.keys + %w[serum cream cleanser spf hair lips mask body candle oil]).freeze
  IMAGE_LABELS = PHOTO_INFO.transform_values { |details| details.fetch("product_type") }.freeze

  belongs_to :category
  has_many :reviews, dependent: :destroy
  has_many :order_items, dependent: :restrict_with_error

  validates :name, presence: true, length: { maximum: 110 }
  validates :description, presence: true, length: { maximum: 2000 }
  validates :price_cents, numericality: { only_integer: true, greater_than: 0 }
  validates :stock, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :image_name, inclusion: { in: IMAGES }

  scope :available, -> { where(active: true) }

  def price_uah
    format("%.2f", price_cents.to_i / 100.0)
  end

  def price_uah=(value)
    amount = BigDecimal(value.to_s.strip.tr(",", "."))
    self.price_cents = (amount * 100).round(0).to_i
  rescue ArgumentError
    self.price_cents = nil
  end

  def average_rating
    reviews.average(:rating)&.round(1)
  end
end
