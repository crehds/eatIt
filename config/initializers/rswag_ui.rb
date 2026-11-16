Rswag::Ui.configure do |c|
  # OpenAPI documents listed in the Swagger UI at /api-docs.
  c.openapi_endpoint "/api-docs/v1/swagger.yaml", "eatIt API v1"

  # Swagger UI would otherwise send the document URL to validator.swagger.io on any public host.
  c.config_object[:validatorUrl] = nil
end
