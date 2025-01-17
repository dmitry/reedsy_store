require "test_helper"

class Product::CalculateTest < ActiveSupport::TestCase
  test "validate uniqueness of items and item attributes" do
    calculation = Product::Calculation.new(
      [
        { id: products(:mug).id, quantity: 2 },
        { id: products(:mug).id, quantity: 1 },
        { id: products(:hoodie).id, quantity: 0 },
        { id: 0, quantity: 2 }
      ]
    )
    assert calculation.invalid?
    errors = {
      base: [ "Products must be unique" ],
      "items[2].quantity": [ "must be greater than 0" ],
      "items[3].product": [ "can't be blank" ]
    }
    assert_equal errors, calculation.errors.messages
    assert_raise ActiveModel::ValidationError do
      calculation.result
    end
  end

  test "calculate total price and item details correctly" do
    calculation = Product::Calculation.new(
      [
        { id: products(:mug).id, quantity: 2 },
        { id: products(:hoodie).id, quantity: 1 },
        { id: products(:tshirt).id, quantity: 5 }
      ]
    )
    assert calculation.valid?
    assert_equal({}, calculation.errors.messages)
    assert_equal(
      {
        items: [
          {
            id: products(:mug).id,
            quantity: 2,
            prices: {
              per_item: "6.0",
              total: "12.0",
              total_raw: "12.0"
            }
          },
          {
            id: products(:hoodie).id,
            quantity: 1,
            prices: {
              per_item: "20.0",
              total: "20.0",
              total_raw: "20.0"
            }
          },
          {
            id: products(:tshirt).id,
            quantity: 5,
            prices: {
              per_item: "15.0",
              total: "52.5",
              total_raw: "75.0"
            }
          }
        ],
        discounted_total: "84.5",
        base_total: "107.0"
      },
      calculation.result
    )
  end
end