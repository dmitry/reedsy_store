class Product < ApplicationRecord
  validates :code,
            presence: true,
            uniqueness: true,
            length: { maximum: 20 }
  validates :name,
            presence: true,
            length: { maximum: 100 }
  validates :price,
            presence: true,
            numericality: {
              greater_than: 0
            }

  normalizes :code, with: -> { it.upcase }

  def as_json(options = {})
    {
      id: id,
      code: code,
      name: name,
      price: price.to_s
    }
  end
end
