products_data = [
  { code: 'MUG', name: 'Reedsy Mug', price: '6.00' },
  { code: 'TSHIRT', name: 'Reedsy T-shirt', price: '15.00' },
  { code: 'HOODIE', name: 'Reedsy Hoodie', price: '20.00' }
]

unless Product.exists?
  products_data.each do |attributes|
    Product.find_or_create_by!(code: attributes[:code]) do |product|
      p attributes
      product.attributes = attributes
    end
  end
end

unless ProductDiscount.exists?
  tshirt = Product.find_by!(code: 'TSHIRT')
  ProductDiscount.create!(product: tshirt, min_quantity: 3, percentage: 30)

  mug = Product.find_by!(code: 'MUG')
  (10..150).step(10) do |qty|
    percentage = (qty / 10.0) * 2
    ProductDiscount.create!(product: mug, min_quantity: qty, percentage: percentage)
  end
end