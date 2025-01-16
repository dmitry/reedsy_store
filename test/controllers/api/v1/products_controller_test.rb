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
    assert_equal @hoodie.id, product["id"]
    assert_equal @hoodie.code, product["code"]
    assert_equal @hoodie.name, product["name"]
    assert_equal @hoodie.price.to_s, product["price"]
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
      json,
      {
        "id" => @mug.id,
        "code" => @mug.code,
        "name" => @mug.name,
        "price" => "10.88"
      }
    )

    assert_equal @mug.reload.price.to_s, "10.88"
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
    @mug = products(:mug)
    assert_equal(
      json,
      {
        "errors" => {
          "price" => [
            "must be greater than 0"
          ]
        }
      }
    )

    assert_equal @mug.reload.price.to_s, "6.0"
  end
end
