require "rails_helper"
require "rake"

RSpec.describe "demo:reset" do
  before(:all) do
    Rails.application.load_tasks unless Rake::Task.task_defined?("demo:reset")
  end

  def reset
    Rake::Task["demo:reset"].tap(&:reenable).invoke
  end

  def seed
    load Rails.root.join("db/seeds.rb")
  end

  def fixture_count(name)
    YAML.safe_load_file(Rails.root.join("spec/fixtures/#{name}.yml")).size
  end

  it "throws away what visitors changed and restores the demo data" do
    seed
    create(:product, name: "Visitor Pizza", demo: true)
    Product.find_by!(name: "Full Rack Ribs", demo: true).update!(price: 1)
    Order.create!(delivery_address: "Visitor Street")

    expect { reset }.to output(/Demo data reset/).to_stdout

    expect(Product.where(demo: true).count).to eq(fixture_count("products"))
    expect(Product.exists?(name: "Visitor Pizza")).to be(false)
    expect(Product.find_by!(name: "Full Rack Ribs", demo: true).price).to eq(9)
    expect(Order.where(demo: true).count).to eq(fixture_count("orders"))
    expect(OrderDetail.count).to eq(fixture_count("order_details"))
  end

  it "never touches the owner's data, even with the same names as the demo" do
    # Chicken Crispers appears in three demo orders, so a seed lookup that ignored the space
    # would hang demo order details on the owner's product and leave the demo without it.
    owner_product = create(:product, name: "Chicken Crispers", demo: false, price: 50)
    owner_order = Order.create!(delivery_address: "My Home", demo: false)
    owner_order.order_details.create!(product: owner_product, quantity: 3)

    expect { reset }.to output.to_stdout

    expect(owner_product.reload.price).to eq(50)
    expect(owner_product.order_details.pluck(:order_id)).to eq([owner_order.id])
    expect(owner_order.reload.order_details.count).to eq(1)
    expect(Product.where(demo: true).count).to eq(fixture_count("products"))
    expect(Product.where(demo: true, name: "Chicken Crispers").count).to eq(1)
  end
end
