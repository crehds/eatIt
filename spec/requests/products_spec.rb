require "rails_helper"

RSpec.describe "Products endpoint", type: :request do
  describe "GET /products" do
    it "should return OK" do
      get "/products"
      payload = JSON.parse(response.body)
      expect(payload).to be_empty
      expect(response).to have_http_status(200)
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
  end
end
