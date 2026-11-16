Rswag::Api.configure do |c|
  # Serve the OpenAPI documents that `bin/rails rswag:specs:swaggerize` writes to swagger/.
  c.openapi_root = Rails.root.join("swagger").to_s
end
