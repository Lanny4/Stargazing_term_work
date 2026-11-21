class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  helper_method :current_user, :signed_in?, :cart_count, :cart_contents, :cart_subtotal, :favorite_ids, :favorite_count, :favorite?

  private

  def current_user
    return @current_user if defined?(@current_user)
    @current_user = User.find_by(id: session[:user_id]) if session[:user_id]
  end

  def signed_in?
    current_user.present?
  end

  def require_login
    return if signed_in?
    redirect_to new_session_path, alert: "Увійдіть до облікового запису, щоб продовжити"
  end

  def require_admin
    return if signed_in? && current_user.admin?
    redirect_to root_path, alert: "Доступ дозволений лише адміністратору"
  end

  def favorite_ids
    Array(session[:favorite_ids]).map(&:to_i).select(&:positive?).uniq.first(60)
  end

  def favorite_count
    favorite_ids.size
  end

  def favorite?(product)
    favorite_ids.include?(product.id)
  end

  def cart_hash
    session[:cart].is_a?(Hash) ? session[:cart] : {}
  end

  def cart_count
    cart_hash.values.sum(&:to_i)
  end

  def cart_contents
    product_ids = cart_hash.keys.map(&:to_i)
    products = Product.where(id: product_ids).index_by { |p| p.id.to_s }
    cart_hash.filter_map do |id, quantity|
      product = products[id]
      next unless product && quantity.to_i.positive?
      { product: product, quantity: quantity.to_i, line_total: product.price_cents * quantity.to_i }
    end
  end

  def cart_subtotal
    cart_contents.sum { |item| item[:line_total] }
  end
end
