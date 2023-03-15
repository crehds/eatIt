FactoryBot.define do
  factory :order do
    delivery_address { Faker::Address.street_address }
  end
end

def order_with_details(order_details_count)
  FactoryBot.attributes_for(:order) do |order|
    items = order_details_as_items(order_details_count)
    return [order, items]
  end
end
