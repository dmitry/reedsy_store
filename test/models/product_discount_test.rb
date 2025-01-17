require "test_helper"

class ProductDiscountTest < ActiveSupport::TestCase
  test "valid discount should save" do
    discount = ProductDiscount.new(
      product: products(:tshirt),
      min_quantity: 20,
      percentage: 40.0
    )
    assert discount.valid?
  end

  test "percentage must be positive and not exceed 100" do
    ProductDiscount.delete_all

    discount = ProductDiscount.new(
      product: products(:mug),
      min_quantity: 10
    )

    discount.percentage = 0
    assert_not discount.valid?

    discount.percentage = 101
    assert_not discount.valid?

    discount.percentage = 30
    assert discount.valid?
  end

  test "min_quantity must be positive" do
    discount = ProductDiscount.new(
      product: products(:tshirt),
      percentage: 2.0
    )

    discount.min_quantity = 0
    assert_not discount.valid?

    discount.min_quantity = -1
    assert_not discount.valid?

    discount.min_quantity = 20
    assert discount.valid?
  end

  test "min_quantity must be unique per product" do
    ProductDiscount.create!(
      product: products(:tshirt),
      min_quantity: 10,
      percentage: 2.0
    )

    duplicate = ProductDiscount.new(
      product: products(:tshirt),
      min_quantity: 10,
      percentage: 5.0
    )

    assert_not duplicate.valid?
    assert_includes duplicate.errors[:min_quantity], "has already been taken"
  end
end
