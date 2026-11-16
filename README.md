# eatIt API

REST API for a restaurant: the products on its menu and the orders placed for them. Built with Rails 8.1 (API-only) and PostgreSQL, documented with OpenAPI generated from the test suite, and deployed on Railway.

**Live:** https://eatit-production-acb74386.up.railway.app/ opens the interactive documentation (Swagger UI). Pick any endpoint and use **Try it out** on the public demo data.

## Highlights

| What | How |
|------|-----|
| Documentation that cannot drift | The OpenAPI document is built from rswag request specs that call the real API, and a coverage spec fails when a route is missing from it |
| Public demo next to private data | One database: requests without a token use the demo data; the owner's bearer token reaches private records that visitors cannot see, change or infer |
| Self-cleaning demo | A daily Railway cron job deletes whatever visitors changed and reloads the original menu and orders |
| Low-cost hosting | The API sleeps when idle (Serverless) and the reset job is billed only while it runs |
| Maintained, not abandoned | Upgraded from Ruby 3.1 / Rails 7.0 to Ruby 3.4 / Rails 8.1 one Rails version at a time, with the suite green at every step |

## Tech stack

| Area | Choice |
|------|--------|
| Language and framework | Ruby 3.4.12, Rails 8.1 (API-only), Puma |
| Database | PostgreSQL |
| Tests | RSpec, FactoryBot, Shoulda Matchers, Faker |
| API documentation | rswag (OpenAPI 3.0 + Swagger UI) |
| Hosting | Railway: Railpack builds, Postgres, cron service, configuration as code in `.railway/railway.ts` |

## Endpoints

| Method | Path | What it does |
|--------|------|--------------|
| `GET` | `/health` | Health check |
| `GET`, `POST` | `/products` | List the menu, add a product |
| `GET`, `PATCH`, `PUT`, `DELETE` | `/products/{id}` | Show, update or delete a product |
| `GET`, `POST` | `/orders` | List orders, create an order with its items |
| `GET`, `PATCH`, `PUT`, `DELETE` | `/orders/{id}` | Show, update (delivery address) or delete an order |

The full contract, with request bodies, responses and errors, lives in the Swagger UI.

### Demo data and owner data

| Request | Data it reads and changes |
|---------|---------------------------|
| No `Authorization` header | The public demo data, which anyone can change |
| `Authorization: Bearer <OWNER_API_TOKEN>` (Swagger UI: **Authorize**) | The owner's private data, invisible to visitors |
| Any other token, or no `OWNER_API_TOKEN` on the server | Rejected with `401 {"error": "Invalid token"}` |

Orders can only use products from their own space.

## Run it locally

Requirements: Ruby 3.4.12 (see `.ruby-version`), PostgreSQL, and a Postgres role named after your OS user that can create databases (`sudo -u postgres createuser --createdb "$USER"`). The development and test databases connect through the local socket as that user, with no password.

1. Install the gems: `bundle install`
2. Create the databases and load the demo data: `bin/rails db:prepare && bin/rails db:seed`
3. Start the server: `bin/rails server`, then open http://localhost:3000/

To try the owner space locally, start the server with a token of your choice: `OWNER_API_TOKEN=local-secret bin/rails server`, then use **Authorize** in the Swagger UI with `local-secret`.

## Tests and documentation

```bash
bundle exec rspec
```

The suite covers models, requests, the owner space, the seeds, the demo reset and the rswag documentation specs.

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

## Demo reset

`bin/rails demo:reset` deletes the demo products and orders, including whatever visitors changed, and loads the seeds again in one transaction. The owner's private data is never touched. The seeds are idempotent and read the demo menu and orders from `spec/fixtures`.

## Deployment (Railway)

The API runs on Railway: an `eatit` service built with Railpack, an `eatit-demo-reset` cron service, and a Railway Postgres.

### Quick path

1. Install the Railway CLI (`brew install railway` or `npm install -g @railway/cli`) and log in: `railway login`.
2. Link this directory to the project: `railway link` (project `eatIt`, service `eatit`).
3. Deploy by pushing to `main`: Railway builds the GitHub repository and deploys it. `railway up --service eatit` deploys the local code instead, for a quick test.

Each deploy runs `bin/rails db:prepare && bin/rails db:seed` first. The `eatit-demo-reset` service runs `bin/rails demo:reset` every day at 06:00 UTC.

### Details

| Topic | Where |
|-------|-------|
| Service settings (source, start, pre-deploy, health check, cron) | `.railway/railway.ts`, applied with `railway config plan` and `railway config apply` |
| SDK that `railway.ts` imports | `npm install railway` in the repository root; `package.json` and `node_modules` stay out of git |
| API variables | Managed on Railway, never in the repository: `DATABASE_URL` (reference to the Postgres service), `RAILS_ENV`, `RAILS_MASTER_KEY` (the content of `config/master.key`), `OWNER_API_TOKEN` (opens the owner's private data) |
| Cron service variables | `DATABASE_URL` (reference to the Postgres service), `RAILS_ENV=production`, `SECRET_KEY_BASE_DUMMY=1` (the reset needs no secrets) |
| Health check | `GET /health` |
| Serverless | `eatit` sleeps after 10 minutes without traffic; the first request after that waits a few seconds for the app to boot and may get a 502 |
| HTTPS | Railway terminates TLS; production uses `assume_ssl` and `force_ssl` |
