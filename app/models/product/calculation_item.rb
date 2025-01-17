class Product::CalculationItem
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :id, :integer
  attribute :quantity, :integer

  validates :id, presence: true
  validates :quantity,
            presence: true,
            numericality: { greater_than: 0, allow_blank: true }
  validates :product, presence: true

  def initialize(item)
    super
  end

  def product
    @product ||= Product.find_by(id: id)
  end

  def total_price
    @total_price ||= total_price_without_cache
  end

  def as_json
    {
      id: id,
      quantity: quantity,
      prices: {
        per_item: product.price,
        total: total_price
      }
    }
  end

  private

  def total_price_without_cache
    return 0 unless product

    product.price * quantity
  end
end
