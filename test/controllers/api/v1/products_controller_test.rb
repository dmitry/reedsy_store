require "test_helper"

class Api::V1::ProductsControllerTest < ActionDispatch::IntegrationTest
  # index
  test "returns all products" do
    get api_v1_products_url
    assert_response :success

    json = response.parsed_body
    assert_equal 3, json.length

    product = json.first
    assert_equal %w[id code name price], product.keys

    @hoodie = products(:hoodie)
    assert_equal product["id"], @hoodie.id
    assert_equal product["code"], @hoodie.code
    assert_equal product["name"], @hoodie.name
    assert_equal product["price"], @hoodie.price.to_s
  end

  test "returns empty array when no products exist" do
    Product.destroy_all

    get api_v1_products_url
    assert_response :success

    json_response = JSON.parse(response.body)
    assert_empty json_response
  end

  # update
  test "updates a product with price" do
    patch api_v1_product_url(
            id: products(:mug),
            product: {
              code: "change",
              name: "new",
              price: 10.884
            }
          )
    assert_response :success

    json = response.parsed_body
    @mug = products(:mug)
    assert_equal(
      {
        "id" => @mug.id,
        "code" => @mug.code,
        "name" => @mug.name,
        "price" => "10.88"
      },
      json
    )

    assert_equal "10.88", @mug.reload.price.to_s
  end

  test "returns validation errors for product with wrong price" do
    patch api_v1_product_url(
            id: products(:mug),
            product: {
              price: -2
            }
          )
    assert_response :unprocessable_entity

    json = response.parsed_body
    assert_equal(
      {
        "errors" => {
          "price" => [
            "must be greater than 0"
          ]
        }
      },
      json
    )

    @mug = products(:mug)
    assert_equal "6.0", @mug.reload.price.to_s
  end

  # calculate
  test "checks price with valid items" do
    valid_items = [
      { id: products(:mug).id, quantity: 3 },
      { id: products(:hoodie).id, quantity: 1 },
      { id: products(:tshirt).id, quantity: 5 }
    ]
    post calculate_api_v1_products_url, params: { items: valid_items }, as: :json
    assert_response :success
    json = response.parsed_body
    assert_equal(
      {
        "items" => [
          {
            "id" => products(:mug).id,
            "quantity" => 3,
            "prices" => {
              "per_item" => "6.0",
              "total" => "18.0",
              "total_raw" => "18.0"
            }
          },
          {
            "id" => products(:hoodie).id,
            "quantity" => 1,
            "prices" => {
              "per_item" => "20.0",
              "total" => "20.0",
              "total_raw" => "20.0"
            }
          },
          {
            "id" => products(:tshirt).id,
            "quantity" => 5,
            "prices" => {
              "per_item" => "15.0",
              "total" => "52.5",
              "total_raw" => "75.0"
            }
          }
        ],
        "discounted_total" => "90.5",
        "base_total" => "113.0"
      },
      json
    )
  end

  test "returns errors for invalid items" do
    invalid_items = [
      { id: products(:mug).id, quantity: 2 },
      { id: products(:mug).id, quantity: 1 }, # Duplicate product
      { id: products(:hoodie).id, quantity: 0 }, # Invalid quantity
      { id: 0, quantity: 2 } # Non-existent product
    ]

    post calculate_api_v1_products_url, params: { items: invalid_items }, as: :json
    assert_response :unprocessable_entity

    assert_equal(
      {
        "errors" => {
          "base" => [ "Products must be unique" ],
          "items[2].quantity" => [ "must be greater than 0" ],
          "items[3].product" => [ "can't be blank" ]
        }
      },
      response.parsed_body
    )
  end
end
