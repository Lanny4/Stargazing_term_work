class PagesController < ApplicationController
  def home
    @featured_products = Product.available.includes(:category).order(id: :desc).limit(4)
  end

  def about; end
  def delivery; end
end
