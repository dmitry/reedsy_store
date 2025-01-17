require "test_helper"

class ProductTest < ActiveSupport::TestCase
  test "valid product should save" do
    product = products(:mug)
    assert product.persisted?
  end

  test "code should be present" do
    product = products(:mug)
    product.code = nil
    assert_not product.valid?
    assert_includes product.errors[:code], "can't be blank"
  end

  test "code should be unique when it is in the other case" do
    product = Product.new(
      code: products(:mug).code.downcase,
      name: "Another Mug",
      price: 7.00
    )
    assert_not product.valid?
    assert_includes product.errors[:code], "has already been taken"
  end

  test "code should be automatically upcased" do
    product = Product.new(
      code: "lower",
      name: "Test Product",
      price: 10.00
    )
    product.valid?
    assert_equal "LOWER", product.code
  end

  test "name should be present" do
    product = products(:mug)
    product.name = nil
    assert_not product.valid?
    assert_includes product.errors[:name], "can't be blank"
  end

  test "price should be present and greater than 0" do
    product = products(:mug)

    product.price = nil
    assert_not product.valid?
    assert_includes product.errors[:price], "can't be blank"

    product.price = 0
    assert_not product.valid?
    assert_includes product.errors[:price], "must be greater than 0"
  end

  test "price should be coerced and rounded" do
    product = products(:mug)

    product.price = "0.085"
    assert product.valid?
    assert_equal BigDecimal("0.09"), product.price

    product.price = "0.084"
    assert product.valid?
    assert_equal BigDecimal("0.08"), product.price
  end

  test "as_json should return the correct format" do
    product = products(:mug)
    json = product.as_json

    assert_equal json[:id], product.id
    assert_equal "MUG", json[:code]
    assert_equal "Reedsy Mug", json[:name]
    assert_equal "6.0", json[:price]
  end
end