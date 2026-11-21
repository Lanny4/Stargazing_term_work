class CartController < ApplicationController
  def show
    @items = cart_contents
  end

  def add
    product = Product.available.find(params[:product_id])
    quantity = Integer(params.fetch(:quantity, 1), exception: false)
    return redirect_to product_path(product), alert: "Введіть кількість від 1 до 99" unless quantity&.between?(1, 99)
    cart = cart_hash.dup
    new_quantity = cart.fetch(product.id.to_s, 0).to_i + quantity
    if new_quantity > product.stock || new_quantity > 99
      redirect_to product_path(product), alert: "Недостатньо товару на складі"
    else
      cart[product.id.to_s] = new_quantity
      session[:cart] = cart
      redirect_to cart_path, notice: "Товар додано до кошика"
    end
  end

  def update
    product = Product.available.find(params[:product_id])
    quantity = Integer(params[:quantity], exception: false)
    return redirect_to cart_path, alert: "Введіть коректну кількість" unless quantity && quantity.between?(0, 99)
    return redirect_to cart_path, alert: "Недостатньо товару" if quantity > product.stock
    cart = cart_hash.dup
    quantity.zero? ? cart.delete(product.id.to_s) : cart[product.id.to_s] = quantity
    session[:cart] = cart
    redirect_to cart_path, notice: "Кошик оновлено"
  end

  def remove
    cart = cart_hash.dup
    cart.delete(params[:product_id].to_s)
    session[:cart] = cart
    redirect_to cart_path, notice: "Товар видалено з кошика"
  end
end
