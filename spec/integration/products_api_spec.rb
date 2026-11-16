require "swagger_helper"

RSpec.describe "Products API", type: :request do
  path "/products" do
    get "Lists the products" do
      tags "Products"
      produces "application/json"

      response "200", "products listed" do
        schema type: :array, items: { "$ref" => "#/components/schemas/product" }
        before { create_list(:product, 2) }

        run_test! do |response|
          expect(JSON.parse(response.body).size).to eq(2)
        end
      end

      response "401", "the Authorization header holds a token that is not the owner's" do
        schema "$ref" => "#/components/schemas/unauthorized"
        let(:Authorization) { "Bearer not-the-owner-token" }

        run_test! do |response|
          expect(JSON.parse(response.body)).to eq("error" => "Invalid token")
        end
      end
    end

    post "Creates a product" do
      tags "Products"
      consumes "application/json"
      produces "application/json"
      parameter name: :payload, in: :body,
                schema: { "$ref" => "#/components/schemas/product_create_payload" }

      response "201", "product created" do
        schema "$ref" => "#/components/schemas/product"
        let(:payload) { { product: attributes_for(:product_params) } }

        run_test! do |response|
          expect(JSON.parse(response.body)["name"]).to eq(payload[:product][:name])
          expect(Product.count).to eq(1)
        end
      end

      response "422", "invalid product" do
        schema "$ref" => "#/components/schemas/validation_errors"
        let(:payload) { { product: { name: "" } } }

        run_test! do |response|
          errors = JSON.parse(response.body)
          expect(errors.keys).to include("name", "price", "description", "category")
          expect(Product.count).to eq(0)
        end
      end
    end
  end

  path "/products/{id}" do
    parameter name: :id, in: :path, type: :integer, description: "Product id"

    get "Shows a product" do
      tags "Products"
      produces "application/json"

      response "200", "product found" do
        schema "$ref" => "#/components/schemas/product"
        let(:id) { create(:product).id }

        run_test! do |response|
          expect(JSON.parse(response.body)["id"]).to eq(id)
        end
      end

      response "404", "product not found" do
        schema "$ref" => "#/components/schemas/not_found"
        let(:id) { 0 }

        run_test!
      end
    end

    patch "Updates a product" do
      tags "Products"
      description "PUT /products/{id} behaves the same way."
      consumes "application/json"
      produces "application/json"
      parameter name: :payload, in: :body,
                schema: { "$ref" => "#/components/schemas/product_update_payload" }

      let(:id) { create(:product).id }

      response "200", "product updated" do
        schema "$ref" => "#/components/schemas/product"
        let(:payload) { { product: { price: 42 } } }

        run_test! do |response|
          expect(JSON.parse(response.body)["price"]).to eq(42)
          expect(Product.find(id).price).to eq(42)
        end
      end

      response "422", "invalid product" do
        schema "$ref" => "#/components/schemas/validation_errors"
        let(:payload) { { product: { name: "" } } }

        run_test! do |response|
          expect(JSON.parse(response.body)).to include("name")
        end
      end

      response "404", "product not found" do
        schema "$ref" => "#/components/schemas/not_found"
        let(:id) { 0 }
        let(:payload) { { product: { price: 42 } } }

        run_test!
      end
    end

    delete "Deletes a product" do
      tags "Products"
      produces "application/json"

      response "200", "product deleted" do
        schema "$ref" => "#/components/schemas/message"
        let(:id) { create(:product).id }

        run_test! do |response|
          expect(JSON.parse(response.body)).to eq("message" => "Product deleted")
          expect(Product.exists?(id)).to be(false)
        end
      end

      response "404", "product not found" do
        schema "$ref" => "#/components/schemas/not_found"
        let(:id) { 0 }

        run_test!
      end
    end
  end
end
