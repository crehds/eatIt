require "swagger_helper"

RSpec.describe "Orders API", type: :request do
  let!(:products) { create_list(:product, 2) }

  path "/orders" do
    get "Lists the orders" do
      tags "Orders"
      produces "application/json"

      response "200", "orders listed" do
        schema type: :array, items: { "$ref" => "#/components/schemas/order" }
        before { create(:order) }

        run_test! do |response|
          expect(JSON.parse(response.body).size).to eq(1)
        end
      end
    end

    post "Creates an order with its items" do
      tags "Orders"
      description "Creates the order and one detail per item in a single transaction: " \
                  "if anything fails, nothing is saved."
      consumes "application/json"
      produces "application/json"
      parameter name: :payload, in: :body,
                schema: { "$ref" => "#/components/schemas/order_create_payload" }

      response "201", "order created" do
        schema "$ref" => "#/components/schemas/order"
        let(:payload) do
          {
            order: { delivery_address: "123 Main Street" },
            items: products.map { |product| { id: product.id, quantity: 2 } }
          }
        end

        run_test! do |response|
          order = Order.find(JSON.parse(response.body)["id"])
          expect(order.order_details.pluck(:product_id)).to match_array(products.map(&:id))
        end
      end

      response "422", "invalid order or no items" do
        schema oneOf: [
          { "$ref" => "#/components/schemas/validation_errors" },
          { "$ref" => "#/components/schemas/message" }
        ]

        context "without a delivery address" do
          let(:payload) do
            { order: { delivery_address: "" }, items: [{ id: products.first.id, quantity: 1 }] }
          end

          run_test! do |response|
            expect(JSON.parse(response.body)).to include("delivery_address")
            expect(Order.count).to eq(0)
          end
        end

        context "without items" do
          let(:payload) { { order: { delivery_address: "123 Main Street" } } }

          run_test! do |response|
            expect(JSON.parse(response.body)).to eq("message" => "The order not has items to save")
            expect(Order.count).to eq(0)
          end
        end
      end

      response "404", "an item references a product that does not exist" do
        schema "$ref" => "#/components/schemas/not_found"
        let(:payload) do
          { order: { delivery_address: "123 Main Street" }, items: [{ id: 0, quantity: 1 }] }
        end

        run_test! do
          expect(Order.count).to eq(0)
        end
      end
    end
  end

  path "/orders/{id}" do
    parameter name: :id, in: :path, type: :integer, description: "Order id"

    get "Shows an order" do
      tags "Orders"
      produces "application/json"

      response "200", "order found" do
        schema "$ref" => "#/components/schemas/order"
        let(:id) { create(:order).id }

        run_test! do |response|
          expect(JSON.parse(response.body)["id"]).to eq(id)
        end
      end

      response "404", "order not found" do
        schema "$ref" => "#/components/schemas/not_found"
        let(:id) { 0 }

        run_test!
      end
    end

    patch "Updates an order" do
      tags "Orders"
      description "Only the delivery address can change. The API answers 201 Created. " \
                  "PUT /orders/{id} behaves the same way."
      consumes "application/json"
      produces "application/json"
      parameter name: :payload, in: :body,
                schema: { "$ref" => "#/components/schemas/order_update_payload" }

      let(:id) { create(:order).id }

      response "201", "order updated" do
        schema "$ref" => "#/components/schemas/order"
        let(:payload) { { order: { delivery_address: "456 Elm Street" } } }

        run_test! do |response|
          expect(JSON.parse(response.body)["delivery_address"]).to eq("456 Elm Street")
          expect(Order.find(id).delivery_address).to eq("456 Elm Street")
        end
      end

      response "422", "invalid order" do
        schema "$ref" => "#/components/schemas/validation_errors"
        let(:payload) { { order: { delivery_address: "" } } }

        run_test! do |response|
          expect(JSON.parse(response.body)).to include("delivery_address")
        end
      end

      response "404", "order not found" do
        schema "$ref" => "#/components/schemas/not_found"
        let(:id) { 0 }
        let(:payload) { { order: { delivery_address: "456 Elm Street" } } }

        run_test!
      end
    end

    delete "Deletes an order and its details" do
      tags "Orders"
      produces "application/json"

      response "200", "order deleted" do
        schema "$ref" => "#/components/schemas/message"
        let(:id) { create(:order).id }

        run_test! do |response|
          expect(JSON.parse(response.body)).to eq("message" => "Order deleted")
          expect(Order.exists?(id)).to be(false)
          expect(OrderDetail.where(order_id: id)).to be_empty
        end
      end

      response "404", "order not found" do
        schema "$ref" => "#/components/schemas/not_found"
        let(:id) { 0 }

        run_test!
      end
    end
  end
end
