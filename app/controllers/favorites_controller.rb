class FavoritesController < ApplicationController
  def index
    @products = Product.available.includes(:category).where(id: favorite_ids).order(:name)
  end

  def toggle
    product = Product.available.find(params[:product_id])
    ids = favorite_ids
    if ids.include?(product.id)
      ids.delete(product.id)
      notice = "Видалено з обраного"
    else
      ids << product.id
      notice = "Додано до обраного"
    end
    session[:favorite_ids] = ids.last(60)
    redirect_back fallback_location: favorites_path, notice: notice
  end
end
