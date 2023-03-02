require "rails_helper"

RSpec.describe Order, type: :model do
  describe "validations" do
    it "validate presence of required files" do
      should validate_presence_of(:delivery_address)
    end
  end
end
