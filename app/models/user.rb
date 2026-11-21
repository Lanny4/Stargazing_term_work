class User < ApplicationRecord
  has_secure_password
  has_many :orders, dependent: :restrict_with_error
  has_many :reviews, dependent: :destroy

  before_validation :normalize_email
  validates :name, presence: true, length: { minimum: 2, maximum: 80 }
  validates :email, presence: true, uniqueness: { case_sensitive: false },
                    format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :password, length: { minimum: 8 }, if: -> { password.present? }

  private

  def normalize_email
    self.email = email.to_s.strip.downcase
  end
end
