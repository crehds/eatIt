import { defineRailway, project, service } from "railway/iac";
// This repository manages only its own resources in the environment. Other
// repositories export their own partial name.
// See https://docs.railway.com/infrastructure-as-code#multi-repo-projects
export const partial = "eatit";
export default defineRailway(() => {
  const eatit = service("eatit", {
    build: { buildEnvironment: "V3", builder: "RAILPACK" },
    start: "bin/rails server -b ::",
    healthcheck: "/health",
    preDeploy: "bin/rails db:prepare && bin/rails db:seed",
    replicas: { "us-west2": 1 },
  });

  return project("eatIt", {
    variables: { managed: false },
    resources: [eatit],
  });
});
