module Admin
  class OrdersController < BaseController
    def index
      @orders = Order.includes(:user).order(created_at: :desc)
    end

    def update
      @order = Order.find(params[:id])
      @order.change_status_by_admin!(params[:status].to_s)
      redirect_to admin_order_path(@order), notice: "Статус замовлення оновлено"
    rescue Order::CheckoutError => e
      redirect_to admin_order_path(@order), alert: e.message
    end

    def show
      @order = Order.includes(:user, :order_items).find(params[:id])
    end
  end
end
