# FinComm — current status and next steps

**Updated: 2026-11-10**

This is the working roadmap for the Docker Compose milestone. It separates what has been checked from what remains. The target is a locally runnable, connected application stack first; AWS image publishing and Kubernetes follow the project block plan.

## Where we are now

- Terraform defines the VPC foundation and EC2 app infrastructure. IAM has been planned and checked, but not applied.
- Docker Compose currently defines PostgreSQL, `product_catalog`, and `recommendation`.
- The database healthcheck uses `pg_isready`; Compose waits for the database to be healthy before starting `product_catalog`.
- Recommendation uses `product_catalog:3550` to reach the catalog on the Compose network and publishes container port `9001` to host port `9550`.
- On 2026-11-10, the owner ran `scripts/recommendation/verify_recommendation.py` against the running local stack. The gRPC request returned five product IDs. Details are in [`sl-005.md`](scratch-logs/sl-005.md).
- The frontend is part of the planned application stack but is not yet connected to this Compose stack.
- The containers are not deployed to AWS.

## What we are building toward

One command from `docker/` should build and start the full local application stack:

```bash
docker compose up -d --build --wait
```

The end-to-end path should be usable: frontend → recommendation and product catalog → PostgreSQL, with the service connections working inside Compose.

## Remaining work, in order

1. Add the frontend service to Compose and configure its addresses using Compose service names and container ports.
2. Bring the full stack up from a clean state with one Compose command; check container status and verify a real frontend request reaches the backend services.
3. Keep the recommendation gRPC smoke check as a focused way to diagnose its backend connection.
4. Finish the Docker II gate: publish the required image to ECR with a Git SHA tag, then complete the planned networking or environment-variable break-and-debug exercise.
5. Complete the recall, gap review, gate score, and article tasks shown in the tracker before moving to Kubernetes.

## Completion check for the one-command stack goal

Mark the Compose full-stack goal complete after the frontend is included and the clean-start command brings up all required services with a working end-to-end request. The current recommendation smoke check is useful evidence for the backend link, but by itself it does not complete the full-stack goal.
