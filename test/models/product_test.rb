require "test_helper"

class ProductTest < ActiveSupport::TestCase
  def setup
    @category = Category.create!(name: "Обличчя", slug: "face")
  end

  test "ціна задається у гривнях і зберігається в копійках" do
    product = Product.new(name: "Крем", description: "Доглядовий косметичний засіб", category: @category,
                          stock: 3, image_name: "cream", price_uah: "149,99")
    assert product.valid?
    assert_equal 14999, product.price_cents
  end

  test "ціна і залишок повинні бути коректними" do
    product = Product.new(name: "Крем", description: "Доглядовий засіб", category: @category,
                          stock: -1, image_name: "unknown", price_cents: -100)
    assert_not product.valid?
    assert product.errors[:stock].any?
    assert product.errors[:price_cents].any?
  end
end
