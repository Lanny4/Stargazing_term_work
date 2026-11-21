class ReviewsController < ApplicationController
  before_action :require_login

  def create
    @product = Product.available.find(params[:product_id])
    @review = @product.reviews.build(params.require(:review).permit(:rating, :body))
    @review.user = current_user
    if @review.save
      redirect_to product_path(@product), notice: "Дякуємо за ваш відгук!"
    else
      @reviews = @product.reviews.where.not(id: nil).includes(:user).order(created_at: :desc)
      render "products/show", status: :unprocessable_entity
    end
  end
end
