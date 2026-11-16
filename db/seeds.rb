# Demo data for the deployed API: the menu and a few orders, taken from the test fixtures so
# development and production show the same data.
#
# Idempotent on purpose: Railway runs it on every deploy (see railway.json). It recreates demo
# records that are missing and never duplicates them; records added by visitors stay as they are.
fixtures = Rails.root.join("spec/fixtures")
load_fixture = ->(name) { YAML.safe_load_file(fixtures.join("#{name}.yml")) }

products = load_fixture.call("products").transform_values do |attributes|
  Product.find_or_create_by!(name: attributes["name"]) do |product|
    product.assign_attributes(attributes.except("name"))
  end
end

orders = load_fixture.call("orders").transform_values do |attributes|
  Order.find_or_create_by!(delivery_address: attributes["delivery_address"])
end

load_fixture.call("order_details").each_value do |attributes|
  order = orders.fetch(attributes["order"])
  product = products.fetch(attributes["product"])

  OrderDetail.find_or_create_by!(order:, product:) do |detail|
    detail.quantity = attributes["quantity"]
  end
end
