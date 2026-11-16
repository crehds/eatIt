# README

**Live API:** https://eatit-production-acb74386.up.railway.app/ (opens the Swagger UI)

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

`bundle exec rspec` keeps the documentation honest in two ways:

- The rswag specs send real requests, so an endpoint that stops matching its documented schema fails.
- A coverage spec fails when a route is missing from `swagger.yaml`, or the file documents one that no longer exists.

The suite does not regenerate `swagger.yaml`. To check that the committed file is current, for example in CI:

```bash
RAILS_ENV=test bin/rails rswag:specs:swaggerize && git diff --exit-code swagger/v1/swagger.yaml
```

## Deployment (Railway)

The API runs on Railway: an `eatit` service built with Railpack, plus a Railway Postgres.

### Quick path

1. Install the Railway CLI and log in: `railway login`.
2. Link this directory to the project: `railway link` (project `eatIt`, service `eatit`).
3. Deploy the local code: `railway up --service eatit`.

Each deploy runs `bin/rails db:prepare && bin/rails db:seed` first. The seeds are idempotent: they recreate the demo menu and orders from `spec/fixtures` when they are missing and never duplicate them.

### Details

| Topic | Where |
|-------|-------|
| Service settings (start, pre-deploy, health check) | `.railway/railway.ts`, applied with `railway config plan` and `railway config apply` |
| SDK that `railway.ts` imports | `npm install railway` in the repository root; `package.json` and `node_modules` stay out of git |
| Variables | Managed on Railway, never in the repository: `DATABASE_URL` (reference to the Postgres service), `RAILS_ENV`, `SECRET_KEY_BASE` |
| Health check | `GET /health` |
| HTTPS | Railway terminates TLS; production uses `assume_ssl` and `force_ssl` |

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
