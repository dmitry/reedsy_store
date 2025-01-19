class Product < ApplicationRecord
  has_many :discounts, class_name: "ProductDiscount", dependent: :destroy

  validates :code,
            presence: true,
            uniqueness: true,
            length: {
              maximum: 20,
              allow_blank: true
            }
  validates :name,
            presence: true,
            length: {
              maximum: 100,
              allow_blank: true
            }
  validates :price,
            presence: true,
            numericality: {
              greater_than: 0,
              allow_blank: true
            }



  normalizes :code, with: -> { it.upcase }

  def discount_for_quantity(quantity)
    discounts.for_quantity(quantity).first
  end

  def as_json(options = {})
    {
      id: id,
      code: code,
      name: name,
      price: price.to_s
    }
  end
end
