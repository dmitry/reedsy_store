products_data = [
  { code: 'MUG', name: 'Reedsy Mug', price: '6.00' },
  { code: 'TSHIRT', name: 'Reedsy T-shirt', price: '15.00' },
  { code: 'HOODIE', name: 'Reedsy Hoodie', price: '20.00' }
]

products_data.each do |attributes|
  Product.find_or_create_by!(code: attributes[:code]) do |product|
    p attributes
    product.attributes = attributes
  end
end
