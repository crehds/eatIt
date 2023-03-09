FactoryBot.define do
  factory :order do
    delivery_address { Faker::Address.street_address }
  end
end
