require "rails_helper"

RSpec.describe "db/seeds.rb" do
  def seed
    load Rails.root.join("db/seeds.rb")
  end

  def fixture_count(name)
    YAML.safe_load_file(Rails.root.join("spec/fixtures/#{name}.yml")).size
  end

  it "loads the demo menu and orders from the fixtures" do
    expect { seed }.to change(Product, :count).from(0).to(fixture_count("products"))
    expect(Order.count).to eq(fixture_count("orders"))
    expect(OrderDetail.count).to eq(fixture_count("order_details"))
    expect(Product.find_by!(name: "Full Rack Ribs")).to have_attributes(price: 9, category: "ribs")
  end

  it "runs again without duplicating anything" do
    seed

    expect { seed }.not_to change { [Product.count, Order.count, OrderDetail.count] }
  end

  it "recreates demo records that were deleted" do
    seed
    Product.find_by!(name: "Full Rack Ribs").destroy

    seed

    expect(Product.where(name: "Full Rack Ribs").count).to eq(1)
    expect(OrderDetail.count).to eq(fixture_count("order_details"))
  end
end
