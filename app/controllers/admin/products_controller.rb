module Admin
  class ProductsController < BaseController
    before_action :find_product, only: [:edit, :update, :destroy]

    def index
      @products = Product.includes(:category).order(created_at: :desc)
    end

    def new
      @product = Product.new(active: true, stock: 5, image_name: "serum")
    end

    def create
      @product = Product.new(product_params)
      if @product.save
        redirect_to admin_products_path, notice: "Товар створено"
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit; end

    def update
      if @product.update(product_params)
        redirect_to admin_products_path, notice: "Товар оновлено"
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @product.update!(active: false)
      redirect_to admin_products_path, notice: "Товар приховано з каталогу (історію замовлень збережено)"
    end

    private

    def find_product
      @product = Product.find(params[:id])
    end

    def product_params
      params.require(:product).permit(:category_id, :name, :description, :price_uah,
                                       :stock, :image_name, :active)
    end
  end
end
