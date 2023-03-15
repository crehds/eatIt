FactoryBot.define do
  factory :order_details do
    order
    product  { Product.all.sample }
    quantity { Faker::Number.between(from: 1, to: 10) }
  end
end

def order_details_as_items(order_details_count)
  products = Product.all.sample(order_details_count)
  products.map do |product|
    { id: product.id, quantity: Faker::Number.between(from: 1, to: 10) }
  end
end
