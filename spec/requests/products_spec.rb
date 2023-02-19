require "rails_helper"

RSpec.describe "Products endpoint", type: :request do
  describe "GET /products" do
    it "should return OK" do
      get "/products"
      payload = JSON.parse(response.body)
      expect(payload).to be_empty
      expect(response).to have_http_status(200)
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
  end
end
