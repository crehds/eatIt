FactoryBot.define do
  factory :product do
    name { Faker::Food.dish }
    price { Faker::Number.between(from: 10.00, to: 100.00) }
    category { Faker::Number.between(from: 1, to: 6) }
    description { Faker::Food.description }
  end
end
