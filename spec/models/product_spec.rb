require "rails_helper"

RSpec.describe Product, type: :model do
  describe "validations" do
    it "validate presence of required files" do
      should validate_presence_of(:name)
      should validate_presence_of(:price)
      should validate_presence_of(:description)
      should validate_presence_of(:category)
    end

    it "validate uniqueness of name column" do
      should validate_uniqueness_of(:name)
    end
  end

  describe "create a product" do
    let(:test_product) { build(:product) }

    it "should return a product" do
      expect(test_product).to_not be_nil
    end
  end
end
