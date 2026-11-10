# Docker Compose startup order and healthchecks

## Why this matters

Starting a container does not mean the service inside it is ready. PostgreSQL
can still be initializing after its container has started. If the product
catalog tries to connect too early, it can exit before the database accepts
connections. Compose can wait for a readiness check before starting a dependent
service.

## How this project uses it

In `docker/compose.yaml`, the `db` service has this healthcheck:

```yaml
healthcheck:
  test: ["CMD-SHELL", "pg_isready -U astronomy_user -d astronomy_db"]
```

Docker runs `pg_isready` in the database container. A successful result marks
the container healthy because PostgreSQL is accepting connection attempts.
This check does not verify that the product catalog can query the expected
tables or return the expected products; `scripts/product-catalog/verify_data.py`
checks the application data path separately.

The `product_catalog` service declares:

```yaml
depends_on:
  db:
    condition: service_healthy
```

That condition tells Compose to wait for the `db` healthcheck to pass before it
starts `product_catalog`. Short-form `depends_on` only orders startup; it does
not wait for the dependency to become healthy.

When run as `docker compose up -d --wait`, `--wait` makes the command wait until
services are running or healthy before it returns. It is useful for the
one-command workflow, but it is separate from the database healthcheck and the
dependency condition: the healthcheck defines the readiness signal, the
dependency condition gates app startup, and `--wait` waits for the resulting
services to reach their running or healthy state.

## Observed run (2026-11-05)

From the `docker/` directory, the command `docker compose up -d --wait`
completed successfully:

```text
[+] up 2/2
✔ Container docker-db-1              Healthy  8.0s
✔ Container docker-product_catalog-1 Healthy  1.1s
```

This output shows both services reported healthy in this run. The per-container
times are recorded as displayed; they are not added together into a total
startup-time measurement.

## Official documentation

- [Compose services reference: `depends_on` and `healthcheck`](https://docs.docker.com/reference/compose-file/services/) — see the `depends_on` section for short vs long syntax and `service_healthy`, then the `healthcheck` section for how the service health check is configured.
- [Compose startup order](https://docs.docker.com/compose/how-tos/startup-order/) — see how Compose waits for a dependency marked `service_healthy` before starting the dependent service.
- [Compose application model](https://docs.docker.com/compose/intro/compose-application-model/) — see “The Compose file” for default filenames and “Key commands” for `docker compose up` / `down`.
