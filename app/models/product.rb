class Product < ApplicationRecord
  validates :name, presence: true, uniqueness: true
  validates :price, presence: true
  validates :description, presence: true
  validates :category, presence: true
  enum category: {
    starter: 0,
    hamburguer: 1,
    drink: 2,
    crisper: 3,
    complement: 4,
    salad: 5,
    dessert: 6
  }
end
