class OrdersController < ApplicationController
  before_action :require_login

  def index
    @orders = current_user.orders.order(created_at: :desc)
  end

  def show
    @order = current_user.orders.includes(order_items: :product).find(params[:id])
  end

  def pay_demo
    return head :forbidden if Rails.env.production?
    order = current_user.orders.find(params[:id])
    if order.payment_method == "demo_card" && order.status == "placed"
      order.update!(status: "paid")
      redirect_to order_path(order), notice: "Демо-оплата підтверджена. Реальні кошти не списувалися."
    else
      redirect_to order_path(order), alert: "Демо-оплата недоступна для цього замовлення"
    end
  end
end
