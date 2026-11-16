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

  it "marks the fields required to create a product, but not to update one" do
    document = YAML.safe_load_file(Rails.root.join("swagger/v1/swagger.yaml"))
    schemas = document.dig("components", "schemas")

    expect(schemas.dig("product_create_payload", "properties", "product", "required"))
      .to match_array(%w[name description price category])
    expect(schemas.dig("product_update_payload", "properties", "product", "required")).to be_nil
  end

  it "keeps the Swagger UI from sending the docs URL to the swagger.io validator" do
    get "/api-docs/index.html"

    expect(response.body).to include('"validatorUrl":null')
  end
end
