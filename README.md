# README

## API documentation

The API has no frontend: its root redirects to the interactive documentation (Swagger UI).

### Quick path

1. Start the server with `bin/rails server`.
2. Open http://localhost:3000/ and you land on `/api-docs/index.html`.
3. Pick an endpoint and use **Try it out** to send a real request.

### Details

| Topic | Where |
|-------|-------|
| OpenAPI document | `swagger/v1/swagger.yaml`, served at `/api-docs/v1/swagger.yaml` |
| Source of the document | rswag specs in `spec/integration/` |
| Regenerate after changing an endpoint | `RAILS_ENV=test bin/rails rswag:specs:swaggerize` |

`bundle exec rspec` runs the rswag specs too, so a response that stops matching the documentation fails the suite.

This README would normally document whatever steps are necessary to get the
application up and running.

Things you may want to cover:

* Ruby version

* System dependencies

* Configuration

* Database creation

* Database initialization

* How to run the test suite

* Services (job queues, cache servers, search engines, etc.)

* Deployment instructions

* ...
