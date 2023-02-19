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

    it "validate index of name column" do
      should have_db_index(:name)
    end
  end
end
