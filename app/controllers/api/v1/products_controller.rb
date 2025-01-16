class Api::V1::ProductsController < Api::BaseController
  before_action :set_product, only: [ :update ]

  def index
    products = Product.all
    render json: products
  end

  def update
    @product.update!(product_params)
    render json: @product
  end

  private

  def set_product
    @product = Product.find_by!(id: params[:id])
  end

  def product_params
    params.require(:product).permit(:price)
  end
end
