FactoryBot.define do
  factory :order do
    delivery_address { Faker::Address.street_address }

    transient do
      order_details_count { 2 }
    end

    order_details do
      products = Product.all.sample(order_details_count)
      Array.new(order_details_count) do |i|
        association(:order_detail, product: products[i], order: instance)
      end
    end
  end
end

def order_with_details(order_details_count)
  FactoryBot.attributes_for(:order) do |order|
    items = order_details_as_items(order_details_count)
    return [order, items]
  end
end
