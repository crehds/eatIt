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
end
