require "test_helper"

class ShopFlowTest < ActionDispatch::IntegrationTest
  def setup
    @category = Category.create!(name: "Обличчя", slug: "face")
    @product = Product.create!(category: @category, name: "Сироватка", description: "М'яка сироватка для догляду",
                               price_cents: 39900, stock: 10, image_name: "serum")
  end

  test "каталог доступний анонімному відвідувачу" do
    get products_path
    assert_response :success
    assert_match "Сироватка", response.body
  end

  test "головна сторінка і каталог мають окремі маршрути" do
    get root_path
    assert_response :success
    assert_select "h1", text: /Твій всесвіт/
    assert_select ".filter-form", 0

    get products_path
    assert_response :success
    assert_select "h1", text: /Твоя колекція/
    assert_select ".filter-form", 1
  end

  test "реєстрація, кошик, оформлення і перегляд замовлення" do
    post registration_path, params: { user: { name: "Ірина", email: "ira@example.com",
                                                password: "Strongpass123", password_confirmation: "Strongpass123" } }
    assert_redirected_to root_path
    post cart_items_path, params: { product_id: @product.id, quantity: 2 }
    assert_redirected_to cart_path
    get cart_path
    assert_response :success
    post checkout_path, params: { order: { customer_name: "Ірина", phone: "+380991112233",
                                          city: "Київ", address: "вул. Лісова, 5",
                                          shipping_method: "pickup", payment_method: "cod" } }
    assert_response :redirect
    order = Order.last
    assert_equal 79800, order.total_cents
    assert_equal 8, @product.reload.stock
    get order_path(order)
    assert_response :success
  end

  test "гість додає товар до обраного й видаляє його" do
    post toggle_favorite_path(@product)
    assert_redirected_to favorites_path
    get favorites_path
    assert_response :success
    assert_match @product.name, response.body
    post toggle_favorite_path(@product)
    get favorites_path
    assert_no_match @product.name, response.body
  end

  test "сторінки про бренд і доставку доступні без входу" do
    get about_path
    assert_response :success
    get delivery_path
    assert_response :success
  end

  test "анонімний користувач не може залишити відгук" do
    post product_reviews_path(@product), params: { review: { rating: 5, body: "Дуже хороший товар" } }
    assert_redirected_to new_session_path
  end

  test "звичайний користувач не може відкрити адмінпанель" do
    post registration_path, params: { user: { name: "Ірина", email: "ira@example.com",
                                                password: "Strongpass123", password_confirmation: "Strongpass123" } }
    get admin_root_path
    assert_redirected_to root_path
  end

  test "повідомлення підтримки зберігається" do
    assert_difference "ContactMessage.count", 1 do
      post contact_messages_path, params: { contact_message: { name: "Оля", email: "olya@example.com",
                        subject: "Питання", message: "Підкажіть, будь ласка, склад крему" } }
    end
    assert_redirected_to root_path
  end
end
