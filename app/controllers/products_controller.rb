class ProductsController < ApplicationController
  def index
    @categories = Category.order(:name)
    @query = params[:q].to_s.strip.first(80)
    @category = Category.find_by(slug: params[:category]) if params[:category].present?
    scope = Product.available.includes(:category)
    scope = scope.where(category: @category) if @category
    if @query.present?
      pattern = "%#{ActiveRecord::Base.sanitize_sql_like(@query.downcase)}%"
      scope = scope.where("LOWER(products.name) LIKE ? OR LOWER(products.description) LIKE ?", pattern, pattern)
    end
    @sort = params[:sort].to_s
    scope = case @sort
            when "price_low" then scope.order(price_cents: :asc, id: :desc)
            when "price_high" then scope.order(price_cents: :desc, id: :desc)
            else scope.order(created_at: :desc, id: :desc)
            end
    @page = [params[:page].to_i, 1].max
    @total_pages = [(scope.count / 12.0).ceil, 1].max
    @page = [@page, @total_pages].min
    @products = scope.limit(12).offset((@page - 1) * 12)
  end

  def show
    @product = Product.available.find(params[:id])
    @reviews = @product.reviews.includes(:user).order(created_at: :desc)
    @review = Review.new
    @related_products = Product.available.where(category_id: @product.category_id).where.not(id: @product.id).limit(4)
  end
end
