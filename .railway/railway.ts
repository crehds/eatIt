import { defineRailway, github, project, service } from "railway/iac";
// This repository manages only its own resources in the environment. Other
// repositories export their own partial name.
// See https://docs.railway.com/infrastructure-as-code#multi-repo-projects
export const partial = "eatit";
export default defineRailway(() => {
  const eatit = service("eatit", {
    // Declared here so `railway config apply` keeps the GitHub autodeploy connection.
    source: github("crehds/eatIt", { branch: "main" }),
    build: { buildEnvironment: "V3", builder: "RAILPACK" },
    start: "bin/rails server -b ::",
    healthcheck: "/health",
    preDeploy: "bin/rails db:prepare && bin/rails db:seed",
    replicas: { "us-west2": 1 },
    // Serverless: sleeps after 10 minutes without outbound traffic, so an idle portfolio
    // costs almost nothing. The first request after a sleep waits for the boot (and may 502).
    deploy: { sleepApplication: true },
  });

  // Resets the public demo data every day at 06:00 UTC. It runs the task and exits, so it
  // is billed only while it runs. Variables are set outside this file: DATABASE_URL,
  // RAILS_ENV and SECRET_KEY_BASE_DUMMY (the task needs no secrets, so no master key).
  const demoReset = service("eatit-demo-reset", {
    source: github("crehds/eatIt", { branch: "main" }),
    build: { buildEnvironment: "V3", builder: "RAILPACK" },
    start: "bin/rails demo:reset",
    deploy: { cronSchedule: "0 6 * * *", restartPolicyType: "NEVER" },
    replicas: { "us-west2": 1 },
  });

  return project("eatIt", {
    variables: { managed: false },
    resources: [eatit, demoReset],
  });
});
