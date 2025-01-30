class ProductDiscount < ApplicationRecord
  belongs_to :product

  validates :min_quantity,
            presence: true,
            numericality: { greater_than: 0 },
            uniqueness: { scope: :product_id }
  validates :percentage,
            presence: true,
            numericality: { greater_than: 0, less_than_or_equal_to: 100 }
end
