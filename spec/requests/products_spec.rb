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
end
