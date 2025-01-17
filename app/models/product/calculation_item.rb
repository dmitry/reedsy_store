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

    discount = product.discount_for_quantity(quantity)

    if discount
      base_price * (1 - discount.percentage / 100.0)
    else
      base_price
    end
  end
end
