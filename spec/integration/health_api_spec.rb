require "swagger_helper"

RSpec.describe "Health API", type: :request do
  path "/health" do
    get "Checks that the API is up" do
      tags "Health"
      produces "application/json"

      response "200", "the API is up" do
        schema "$ref" => "#/components/schemas/health"

        run_test! do |response|
          expect(JSON.parse(response.body)).to eq("api" => "OK")
        end
      end
    end
  end
end
