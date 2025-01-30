class Product::Calculation
  include ActiveModel::Model
  include ActiveModel::Attributes

  attr_reader :items

  validate :validate_unique_ids
  validate :validate_items

  def initialize(items)
    @items = items_with_products(items) { Product::CalculationItem.new(it) }
  end

  def result
    validate!

    {
      items: items.map(&:as_json),
      discounted_total: discounted_price.to_s,
      base_total: base_price.to_s
    }
  end

  private

  def items_with_products(items)
    ids = items.map { it[:id] }
    products = products_with_discounts(ids)
    items.map { yield(it.merge(product: products[it[:id]])) }
  end

  def products_with_discounts(ids)
    Product
      .eager_load(:discounts)
      .where(id: ids)
      .index_by(&:id)
  end

  def discounted_price
    items.sum(&:discounted_price)
  end

  def base_price
    items.sum(&:base_price)
  end

  def validate_unique_ids
    ids = items.map(&:id)
    if ids.uniq.size != ids.size
      errors.add(:base, :unique)
    end
  end

  def validate_items
    items.each_with_index do |item, index|
      unless item.valid?
        item.errors.each do |error|
          errors.add(
            "items[#{index}].#{error.attribute}",
            error.message,
            **error.details
          )
        end
      end
    end
  end
end
