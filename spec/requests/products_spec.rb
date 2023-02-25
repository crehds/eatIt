require "rails_helper"

RSpec.describe "Products endpoint", type: :request do
  describe "GET /products" do
    it "should return OK" do
      get "/products"
      payload = JSON.parse(response.body)
      expect(payload).to be_empty
      expect(response).to have_http_status(200)
    end
  end

  describe "GET /products/new" do
    let!(:product) { build(:product) }

    it "should return a product" do
      get "/products/new"
      payload = JSON.parse(response.body)

      expect(payload.keys).to eq(product.attributes.keys)
    end
  end

  describe "with data in DB" do
    let!(:products) { create_list(:product, 10) }

    it "should return all products" do
      get "/products"
      payload = JSON.parse(response.body)
      expect(payload.size).to eq(products.size)
      expect(response).to have_http_status(200)
    end
  end

  describe "GET /products/#{id}" do
    let!(:product) { create(:product) }

    it "should return a product" do
      get "/products/#{product.id}"
      payload = JSON.parse(response.body)
      expect(payload).to_not be_empty
      expect(payload["id"]).to eq(product.id)
      expect(response).to have_http_status(200)
    end
  end

  describe "POST /products" do
    let(:product) { attributes_for(:product_params) }
    it "should create a product" do
      post "/products", params: { product: }
      payload = JSON.parse(response.body)
      expect(payload["id"]).to_not be_nil
    end
  end

  describe "PATCH /products/#{id}" do
    let!(:product) { create(:product) }
    let!(:updated_product) { attributes_for(:product_params) }

    it "should update a product" do
      patch "/products/#{product.id}", params: { product: { **updated_product } }

      payload = JSON.parse(response.body)
      expect(payload["id"]).to eq(product.id)
      expect(payload["name"]).to eq(updated_product[:name])
      expect(payload["price"]).to eq(updated_product[:price])
      expect(payload["description"]).to eq(updated_product[:description])
    end
  end
end
