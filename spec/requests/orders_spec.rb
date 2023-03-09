require "rails_helper"

RSpec.describe "Orders", type: :request do
  describe "GET /index" do
    it "should return empty" do
      get "/orders"
      payload = JSON.parse(response.body)
      expect(payload).to be_empty
      expect(response).to have_http_status(200)
    end
  end

  describe "GET /orders/#{id}" do
    let!(:order) { create(:order) }

    it "should return a order" do
      get "/orders/#{order.id}"
      payload = JSON.parse(response.body)
      expect(payload).to_not be_empty
      expect(payload["id"]).to eq(order.id)
    end
  end

  describe "POST /orders" do
    let!(:order) { attributes_for(:order) }
    let!(:order_with_error) { { delivery_address: nil } }

    it "should create a product" do
      post "/orders", params: { order: }

      payload = JSON.parse(response.body)
      expect(payload).to_not be_empty
      expect(payload["id"]).to_not be_nil
      expect(payload["delivery_address"]).to eq(order[:delivery_address])
    end

    it "should don't create a product" do
      post "/orders", params: { order: { **order_with_error } }

      expect(response).to have_http_status(:unprocessable_entity)
      expect(Order.all).to be_empty
    end
  end
end
