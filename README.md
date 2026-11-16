# README

**Live API:** https://eatit-production-acb74386.up.railway.app/ (opens the Swagger UI)

## API documentation

The API has no frontend: its root redirects to the interactive documentation (Swagger UI).

### Quick path

1. Start the server with `bin/rails server`.
2. Open http://localhost:3000/ and you land on `/api-docs/index.html`.
3. Pick an endpoint and use **Try it out** to send a real request.

### Demo data and owner data

| Request | Data it reads and changes |
|---------|---------------------------|
| No `Authorization` header | The public demo data, which anyone can change |
| `Authorization: Bearer <OWNER_API_TOKEN>` (Swagger UI: **Authorize**) | The owner's private data, invisible to visitors |
| Any other token, or no `OWNER_API_TOKEN` on the server | Rejected with `401 {"error": "Invalid token"}` |

Orders can only use products from their own space.

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

1. Install the Railway CLI (`brew install railway` or `npm install -g @railway/cli`) and log in: `railway login`.
2. Link this directory to the project: `railway link` (project `eatIt`, service `eatit`).
3. Deploy by pushing to `main`: Railway builds the GitHub repository and deploys it. `railway up --service eatit` deploys the local code instead, for a quick test.

Each deploy runs `bin/rails db:prepare && bin/rails db:seed` first. The seeds are idempotent: they recreate the demo menu and orders from `spec/fixtures` when they are missing and never duplicate them.

The `eatit-demo-reset` cron service runs `bin/rails demo:reset` every day at 06:00 UTC: it deletes the demo data, including whatever visitors changed, and loads the seeds again. The owner's private data is never touched.

### Details

| Topic | Where |
|-------|-------|
| Service settings (source, start, pre-deploy, health check, cron) | `.railway/railway.ts`, applied with `railway config plan` and `railway config apply` |
| Cron service variables | `DATABASE_URL` (reference to the Postgres service), `RAILS_ENV=production`, `SECRET_KEY_BASE_DUMMY=1` (the reset needs no secrets) |
| SDK that `railway.ts` imports | `npm install railway` in the repository root; `package.json` and `node_modules` stay out of git |
| Variables | Managed on Railway, never in the repository: `DATABASE_URL` (reference to the Postgres service), `RAILS_ENV`, `RAILS_MASTER_KEY` (the content of `config/master.key`), `OWNER_API_TOKEN` (opens the owner's private data) |
| Health check | `GET /health` |
| Serverless | `eatit` sleeps after 10 minutes without traffic; the first request after that waits for the app to boot and may get a 502 |
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
