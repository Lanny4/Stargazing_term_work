class Category < ApplicationRecord
  has_many :products, dependent: :restrict_with_error
  validates :name, :slug, presence: true, uniqueness: true
end
