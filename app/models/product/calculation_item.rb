class Product::CalculationItem
  include ActiveModel::Model
  include ActiveModel::Attributes

  attr_accessor :product

  attribute :id, :integer
  attribute :quantity, :integer

  validates :id, presence: true
  validates :quantity,
            presence: true,
            numericality: { greater_than: 0, allow_blank: true }
  validates :product, presence: true

  def discounted_price
    @discounted_price ||= discounted_price_without_cache
  end

  def base_price
    @base_price ||= (product.price * quantity)
  end

  def as_json
    {
      id: id,
      quantity: quantity,
      prices: {
        per_item: product.price.to_s,
        total: discounted_price.round(2).to_s,
        total_raw: base_price.round(2).to_s
      }
    }
  end

  private

  def discounted_price_without_cache
    return 0 unless product

    if discount
      base_price * (1 - discount.percentage / 100.0)
    else
      base_price
    end
  end

  def discount
    @discount ||= product.discounts.sort_by(&:min_quantity).reverse.find { it.min_quantity <= quantity }
  end

  def product
    @product ||= Product.find_by(id: id)
  end
end
