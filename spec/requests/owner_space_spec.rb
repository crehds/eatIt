require "rails_helper"

RSpec.describe "Owner space", type: :request do
  let(:owner_headers) { { "Authorization" => "Bearer owner-secret" } }
  # A method, not a let: several examples read more than one response.
  def json = JSON.parse(response.body)

  around do |example|
    Rails.configuration.x.owner_api_token = "owner-secret"
    example.run
  ensure
    Rails.configuration.x.owner_api_token = nil
  end

  let!(:demo_product) { create(:product, name: "Demo Ribs", demo: true) }
  let!(:owner_product) { create(:product, name: "My Secret Dish", demo: false) }

  describe "products" do
    it "shows visitors only the demo products" do
      get "/products"

      expect(json.pluck("name")).to eq(["Demo Ribs"])
    end

    it "shows the owner only the owner products" do
      get "/products", headers: owner_headers

      expect(json.pluck("name")).to eq(["My Secret Dish"])
    end

    it "hides an owner product from visitors on show, update and delete" do
      get "/products/#{owner_product.id}"
      expect(response).to have_http_status(:not_found)

      patch "/products/#{owner_product.id}", params: { product: { price: 1 } }
      expect(response).to have_http_status(:not_found)

      delete "/products/#{owner_product.id}"
      expect(response).to have_http_status(:not_found)
      expect(owner_product.reload.price).not_to eq(1)
    end

    it "creates owner products with the token, invisible to visitors" do
      post "/products", headers: owner_headers,
                        params: { product: attributes_for(:product_params, name: "Private Taco") }

      expect(response).to have_http_status(:created)
      expect(Product.find(json["id"]).demo).to be(false)

      get "/products"
      expect(json.pluck("name")).not_to include("Private Taco")
    end

    it "allows an owner product with the same name as a demo product" do
      post "/products", headers: owner_headers,
                        params: { product: attributes_for(:product_params, name: "Demo Ribs") }

      expect(response).to have_http_status(:created)
    end

    it "ignores a demo flag sent by a visitor" do
      post "/products", params: { product: attributes_for(:product_params).merge(demo: false) }

      expect(Product.find(json["id"]).demo).to be(true)
    end
  end

  describe "orders" do
    let!(:owner_order) { Order.create!(delivery_address: "My Home 1", demo: false) }

    it "creates owner orders only from owner products" do
      post "/orders", headers: owner_headers,
                      params: { order: { delivery_address: "My Home 2" },
                                items: [{ id: owner_product.id, quantity: 1 }] }

      expect(response).to have_http_status(:created)
      expect(Order.find(json["id"]).demo).to be(false)
    end

    it "rejects an owner order that uses a demo product, saving nothing" do
      expect do
        post "/orders", headers: owner_headers,
                        params: { order: { delivery_address: "My Home 2" },
                                  items: [{ id: demo_product.id, quantity: 1 }] }
      end.not_to change(Order, :count)

      expect(response).to have_http_status(:not_found)
    end

    it "rejects a visitor order that uses an owner product, saving nothing" do
      expect do
        post "/orders", params: { order: { delivery_address: "Street 1" },
                                  items: [{ id: owner_product.id, quantity: 1 }] }
      end.not_to change(Order, :count)

      expect(response).to have_http_status(:not_found)
    end

    it "hides owner orders from visitors" do
      get "/orders"
      expect(json.pluck("id")).not_to include(owner_order.id)

      get "/orders/#{owner_order.id}"
      expect(response).to have_http_status(:not_found)
    end
  end

  describe "invalid tokens" do
    it "rejects a wrong token with 401 instead of falling back to the demo" do
      expect do
        post "/products", headers: { "Authorization" => "Bearer wrong" },
                          params: { product: attributes_for(:product_params) }
      end.not_to change(Product, :count)

      expect(response).to have_http_status(:unauthorized)
      expect(json).to eq("error" => "Invalid token")
    end

    it "rejects every token when the server has no owner token configured" do
      Rails.configuration.x.owner_api_token = nil

      get "/products", headers: owner_headers

      expect(response).to have_http_status(:unauthorized)
    end

    it "keeps the health check open whatever the Authorization header says" do
      get "/health", headers: { "Authorization" => "Bearer wrong" }

      expect(response).to have_http_status(:ok)
    end
  end
end
