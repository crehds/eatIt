# frozen_string_literal: true

require "rails_helper"

RSpec.configure do |config|
  # `bin/rails rswag:specs:swaggerize` writes the documents here, and rswag-api serves them.
  config.openapi_root = Rails.root.join("swagger").to_s

  product_fields = {
    name: { type: :string, example: "Full Rack Ribs" },
    description: { type: :string, example: "Slow-cooked pork ribs with barbecue sauce." },
    price: { type: :integer, example: 9 },
    category: { type: :string, enum: Product.categories.keys, example: "ribs" }
  }
  delivery_address = { type: :string, example: "123 Main Street" }
  timestamp = { type: :string, format: "date-time" }
  space = {
    type: :boolean,
    description: "true for the public demo data, false for the owner's private data",
    example: true
  }

  config.openapi_specs = {
    "v1/swagger.yaml" => {
      openapi: "3.0.1",
      info: {
        title: "eatIt API",
        version: "v1",
        description: "REST API for a restaurant: manage the products on the menu " \
                     "and the orders placed for them."
      },
      paths: {},
      # A relative server lets "Try it out" call the same host that serves the docs.
      servers: [{ url: "/" }],
      # The token is optional: without it every endpoint works on the public demo data.
      security: [{}, { bearer_auth: [] }],
      components: {
        securitySchemes: {
          bearer_auth: {
            type: :http,
            scheme: :bearer,
            description: "Owner token (OWNER_API_TOKEN). With it, every endpoint works on the " \
                         "owner's private data instead of the public demo data."
          }
        },
        schemas: {
          unauthorized: {
            type: :object,
            properties: { error: { type: :string, example: "Invalid token" } },
            required: %w[error]
          },
          health: {
            type: :object,
            properties: { api: { type: :string, example: "OK" } },
            required: %w[api]
          },
          product: {
            type: :object,
            properties: {
              id: { type: :integer, example: 1 },
              **product_fields,
              demo: space,
              created_at: timestamp,
              updated_at: timestamp
            },
            required: %w[id name description price category demo created_at updated_at]
          },
          product_create_payload: {
            type: :object,
            properties: {
              product: {
                type: :object,
                properties: product_fields,
                required: %w[name description price category]
              }
            },
            required: %w[product]
          },
          product_update_payload: {
            type: :object,
            properties: {
              product: {
                type: :object,
                description: "Only the fields to change.",
                properties: product_fields
              }
            },
            required: %w[product]
          },
          order: {
            type: :object,
            properties: {
              id: { type: :integer, example: 1 },
              delivery_address: delivery_address,
              demo: space,
              created_at: timestamp,
              updated_at: timestamp
            },
            required: %w[id delivery_address demo created_at updated_at]
          },
          order_create_payload: {
            type: :object,
            properties: {
              order: {
                type: :object,
                properties: { delivery_address: delivery_address },
                required: %w[delivery_address]
              },
              items: {
                type: :array,
                description: "Products in the order. An order without items is rejected.",
                items: {
                  type: :object,
                  properties: {
                    id: { type: :integer, description: "Product id", example: 1 },
                    quantity: { type: :integer, example: 2 }
                  },
                  required: %w[id quantity]
                }
              }
            },
            required: %w[order items]
          },
          order_update_payload: {
            type: :object,
            properties: {
              order: {
                type: :object,
                properties: { delivery_address: delivery_address }
              }
            },
            required: %w[order]
          },
          validation_errors: {
            type: :object,
            description: "Validation messages keyed by attribute.",
            additionalProperties: { type: :array, items: { type: :string } },
            example: { name: ["can't be blank"] }
          },
          message: {
            type: :object,
            properties: { message: { type: :string } },
            required: %w[message]
          },
          not_found: {
            type: :object,
            properties: {
              status: { type: :integer, example: 404 },
              error: { type: :string, example: "Not Found" }
            },
            required: %w[status error]
          }
        }
      }
    }
  }

  config.openapi_format = :yaml
end
