class Api::V1::ProductsController < Api::BaseController
  before_action :set_product, only: [ :update ]

  def index
    products = Product.all
    render json: products
  end

  def update
    @product.update!(permit_products)
    render json: @product
  end

  def calculate
    calculation = Product::Calculation.new(permit_items)
    render json: calculation.result
  end

  private

  def set_product
    @product = Product.find_by!(id: params[:id])
  end

  def permit_products
    params.require(:product).permit(:price)
  end

  def permit_items
    params.require(:items).map do |item|
      item.permit(:id, :quantity)
    end
  end
end
