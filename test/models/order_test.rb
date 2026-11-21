require "test_helper"

class OrderTest < ActiveSupport::TestCase
  def setup
    @user = User.create!(name: "Марія", email: "buyer@example.com", password: "Validpass123")
    @category = Category.create!(name: "Тіло", slug: "body")
    @product = Product.create!(name: "Молочко", description: "Молочко для догляду за тілом",
                               category: @category, stock: 3, price_cents: 25000, image_name: "body")
    @details = { customer_name: "Марія", phone: "+380991112233", city: "Івано-Франківськ",
                 address: "вул. Шевченка, 12", shipping_method: "nova_poshta", payment_method: "cod" }
  end

  test "правильно розраховує підсумок і зменшує залишок" do
    order = Order.checkout!(user: @user, cart: { @product.id.to_s => 2 }, attributes: @details)
    assert_equal 50000, order.subtotal_cents
    assert_equal 6500, order.shipping_cents
    assert_equal 56500, order.total_cents
    assert_equal 1, @product.reload.stock
    assert_equal 1, order.order_items.count
  end

  test "не дозволяє купити більше, ніж є в наявності" do
    assert_raises(Order::CheckoutError) do
      Order.checkout!(user: @user, cart: { @product.id.to_s => 5 }, attributes: @details)
    end
    assert_equal 3, @product.reload.stock
    assert_equal 0, Order.count
  end

  test "адміністратор скасовує замовлення і повертає складські залишки" do
    order = Order.checkout!(user: @user, cart: { @product.id.to_s => 2 }, attributes: @details)
    order.change_status_by_admin!("canceled")
    assert_equal "canceled", order.reload.status
    assert_equal 3, @product.reload.stock
    assert_raises(Order::CheckoutError) { order.change_status_by_admin!("canceled") }
    assert_equal 3, @product.reload.stock
  end

  test "не дозволяє змінити скасоване замовлення на відправлене" do
    order = Order.checkout!(user: @user, cart: { @product.id.to_s => 1 }, attributes: @details)
    order.change_status_by_admin!("canceled")
    assert_raises(Order::CheckoutError) { order.change_status_by_admin!("shipped") }
  end

  test "відхиляє некоректну адресу та зберігає залишки" do
    assert_raises(ActiveRecord::RecordInvalid) do
      Order.checkout!(user: @user, cart: { @product.id.to_s => 1 }, attributes: @details.merge(city: ""))
    end
    assert_equal 3, @product.reload.stock
  end
end
