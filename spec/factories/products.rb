FactoryBot.define do
  factory :product do
    name { Faker::Food.unique.dish }
    price { Faker::Number.between(from: 10, to: 100) }
    category { Faker::Number.between(from: 1, to: 6) }
    description { Faker::Food.description }
  end

  factory :product_params, class: "Product" do
    name { Faker::Food.unique.dish }
    price { Faker::Number.between(from: 10, to: 100) }
    category { %w[starter hamburguer drink crisper complement salad dessert].sample }
    description { Faker::Food.description }
  end
end
