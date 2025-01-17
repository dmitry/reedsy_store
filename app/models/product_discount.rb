class ProductDiscount < ApplicationRecord
  belongs_to :product

  validates :min_quantity, presence: true, numericality: { greater_than: 0 }
  validates :percentage, presence: true, numericality: { greater_than: 0, less_than_or_equal_to: 100 }
  validates :min_quantity, uniqueness: { scope: :product_id }

  scope :for_quantity, ->(quantity) {
    where("min_quantity <= ?", quantity).order(percentage: :desc)
  }
end
