require "rails_helper"

RSpec.describe Product, type: :model do
  describe "validations" do
    it "validate presence of required files" do
      should validate_presence_of(:name)
      should validate_presence_of(:price)
      should validate_presence_of(:description)
      should validate_presence_of(:category)
    end

    it "validates name uniqueness within the demo or owner space" do
      should validate_uniqueness_of(:name).scoped_to(:demo)
    end

    it "has a unique index on name and space" do
      should have_db_index(%i[name demo]).unique
    end

    it "allows the same name in the demo and the owner spaces" do
      create(:product, name: "Full Rack Ribs", demo: true)

      expect(build(:product, name: "Full Rack Ribs", demo: false)).to be_valid
    end
  end

  describe "space" do
    it "belongs to the demo space by default" do
      expect(Product.new.demo).to be(true)
    end
  end

  describe "associations" do
    it "validate has many order details" do
      should have_many(:order_details)
    end
  end
end
