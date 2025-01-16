require "test_helper"

class Api::V1::ProductsControllerTest < ActionDispatch::IntegrationTest
  fixtures(:products)

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
end
