class Order < ApplicationRecord
  has_many :order_details, dependent: :destroy

  validates :delivery_address, presence: true
end
