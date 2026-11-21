module Admin
  class DashboardController < BaseController
    def index
      @products_count = Product.count
      @users_count = User.count
      @orders_count = Order.count
      @messages_count = ContactMessage.count
      @latest_orders = Order.includes(:user).order(created_at: :desc).limit(6)
    end
  end
end
