require "rails_helper"

RSpec.describe "API docs", type: :request do
  it "redirects the root to the Swagger UI" do
    get "/"

    expect(response).to have_http_status(:moved_permanently)
    expect(response).to redirect_to("/api-docs/index.html")
  end

  it "serves the OpenAPI document" do
    get "/api-docs/v1/swagger.yaml"

    expect(response).to have_http_status(:ok)
    expect(response.body).to include("title: eatIt API")
  end

  it "serves the Swagger UI" do
    get "/api-docs/index.html"

    expect(response).to have_http_status(:ok)
    expect(response.body).to include("swagger-ui")
  end
end
