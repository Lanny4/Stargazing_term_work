require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "зберігає пароль як хеш і дозволяє вхід" do
    user = User.create!(name: "Тест", email: " TEST@EXAMPLE.COM ", password: "Strongpass123",
                        password_confirmation: "Strongpass123")
    assert_equal "test@example.com", user.email
    assert user.authenticate("Strongpass123")
    assert_not_equal "Strongpass123", user.password_digest
  end

  test "відхиляє дублікат email без врахування регістру" do
    User.create!(name: "Олена", email: "a@example.com", password: "Strongpass123")
    another = User.new(name: "Наталя", email: "A@EXAMPLE.COM", password: "Strongpass123")
    assert_not another.valid?
  end

  test "мінімальна довжина пароля 8" do
    assert_not User.new(name: "Олена", email: "b@example.com", password: "abc").valid?
  end
end
