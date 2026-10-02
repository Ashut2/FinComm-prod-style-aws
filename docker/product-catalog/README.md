# product-catalog (Docker)

Go service. Source copied from the OpenTelemetry demo (`src/product-catalog`).
Listens on gRPC, reads product data from Postgres.

## Prerequisites

- Docker Desktop running.
- PostgreSQL running on the host machine (native install, not a container),
  with the schema from `docker/postgresql/init.sql` already applied.
  See `docs/scratch-logs/sl-dependenct-list-002.md` for how that was set up.

## Environment variables

See `.env.example` in this folder for the full list with placeholders.
Copy it to `.env` and fill in real values — never commit `.env`.

| Variable | Meaning |
|---|---|
| `PRODUCT_CATALOG_PORT` | Port the service listens on (3550) |
| `DB_CONNECTION_STRING` | `postgres://<user>:<password>@<host>:<port>/<database>?sslmode=disable` |

`<host>` is `host.docker.internal` when Postgres runs natively on this
machine and the app runs inside a container — that's the current setup.

## Build

Run from the repo root. The Dockerfile lives here, the source lives in
`application/product-catalog` (that folder is the build context):

```bash
docker build -f docker/product-catalog/Dockerfile -t fincomm/product-catalog:dev application/product-catalog
```

## Run

Replace the placeholders with the real values from `.env` before running:

```bash
docker run -p 3550:3550 \
  -e PRODUCT_CATALOG_PORT=3550 \
  -e DB_CONNECTION_STRING="postgres://<user>:<password>@host.docker.internal:5432/<database>?sslmode=disable" \
  fincomm/product-catalog:dev
```

## Known state

- Single-stage build (~1.35 GB). Ships the full Go toolchain because
  nothing is discarded after compiling. Multi-stage build (Block 3)
  will cut this down to only the compiled binary.
