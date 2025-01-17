class Product::Calculation
  include ActiveModel::Model
  include ActiveModel::Attributes

  attr_reader :items

  validate :validate_unique_ids
  validate :validate_items

  def initialize(items)
    @items = items.map { Product::CalculationItem.new(it) }
  end

  def result
    validate!

    {
      items: items.map(&:as_json),
      total_price: total_price
    }
  end

  private

  def total_price
    items.sum(&:total_price)
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
