class CheckoutsController < ApplicationController
  before_action :require_login
  before_action :require_nonempty_cart

  def new
    @order = current_user.orders.build(customer_name: current_user.name,
                                        shipping_method: "nova_poshta", payment_method: "cod")
    @items = cart_contents
  end

  def create
    attrs = params.require(:order).permit(:customer_name, :phone, :city, :address,
                                           :shipping_method, :payment_method).to_h
    # Демо-оплата не повинна працювати на справжньому production-сайті.
    if Rails.env.production? && attrs["payment_method"] == "demo_card"
      return redirect_to new_checkout_path, alert: "Демо-оплата вимкнена в production"
    end
    @order = Order.checkout!(user: current_user, cart: cart_hash, attributes: attrs)
    session[:cart] = {}
    redirect_to order_path(@order), notice: "Замовлення успішно оформлено"
  rescue Order::CheckoutError, ActiveRecord::RecordInvalid => e
    @order ||= current_user.orders.build(attrs || {})
    @items = cart_contents
    flash.now[:alert] = e.message
    render :new, status: :unprocessable_entity
  end

  private

  def require_nonempty_cart
    redirect_to cart_path, alert: "Кошик порожній" if cart_hash.blank?
  end
end
