class Product < ApplicationRecord
  has_many :order_details, dependent: :destroy

  validates :name, presence: true, uniqueness: { scope: :demo }
  validates :price, presence: true
  validates :description, presence: true
  validates :category, presence: true
  enum :category, {
    appetizer: 0,
    hamburguer: 1,
    drink: 2,
    crisper: 3,
    side: 4,
    salad: 5,
    dessert: 6,
    ribs: 7,
    tacos: 8
  }
end
