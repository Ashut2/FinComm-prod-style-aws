# Docker networking: who talks to whom

Block 2 concept note. Written 2026-10-08 after the blank-page recall.

## Three directions, three tools
Think of Docker as an apartment building and the laptop as the street outside.

| Who talks to whom | What you use | Example from this project |
|---|---|---|
| Container to container (flat to flat, inside the building) | A user-defined network, then the **container name** | `box-a` pinging `box-b` |
| Me to a container (from the street into a flat) | **`-p host:container`** (publishes a port) | `-p 3550:3550`, so `verify_data.py` reaches `localhost:3550` |
| Container to my laptop (from a flat out to the street) | **`host.docker.internal`** | `product-catalog` reaching native Postgres at `host.docker.internal:5432` |

Rule: ask "who is talking to whom?", then pick the tool from that row.

- `-p` is only for traffic coming from **outside** Docker. Two containers on the same network don't need it.
- Inside a container, `localhost` means **the container itself**, not the laptop. This was the bug in incident `docs/scratch-logs/sl-003.md`.

## Default bridge vs user-defined network
- A user-defined network has built-in DNS, so containers find each other **by name**.
- On the default bridge, name lookup does not work.

Evidence from my own experiment (1 Oct 2026, alpine containers, `ping` by name):

| Setup | Result |
|---|---|
| `box-a` to `box-b` on user-defined network `fincomm-test` | resolved to 172.19.0.3, 0% packet loss |
| `box-c` to `box-d` on the default bridge | `bad address 'box-d'` (the name could not be resolved) |

Commands used:
```bash
docker network create fincomm-test
docker run -d --name box-a --network fincomm-test alpine sleep 300
docker run -d --name box-b --network fincomm-test alpine sleep 300
docker exec box-a ping -c 2 box-b
docker rm -f box-a box-b && docker network rm fincomm-test
```

## Correction to my first recall
I wrote that containers on the default bridge are "isolated". That is not accurate: the failure I saw was name resolution (`bad address`), not a blocked connection. Containers on the default bridge are expected to reach each other by IP address.

STATUS: **verified on 2026-10-08.** Two alpine containers (`box-e`, `box-f`) on the default bridge, no `--network` flag:

| Check | Result |
|---|---|
| IP of `box-f` (`docker inspect --format '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' box-f`) | 172.17.0.3 |
| `docker exec box-e ping -c 2 172.17.0.3` (by IP) | works, 0% packet loss |
| `docker exec box-e ping -c 2 box-f` (by name) | `ping: bad address 'box-f'` |

So the default bridge is not isolated: containers reach each other by IP. Only name lookup (DNS) is missing, and a user-defined network adds it.

## Interview one-liner
"On a user-defined network Docker gives containers DNS by name; on the default bridge it doesn't. Publishing a port with `-p` is for traffic from outside, and `host.docker.internal` is how a container reaches the host machine."

## Why it matters next
Compose (Block 3) creates a user-defined network automatically, which is why a compose file can use `product-catalog:3550` as an address. Kubernetes Services do the same job later.

## Official docs (checked 2026-10-09)
- [Bridge network driver](https://docs.docker.com/engine/network/drivers/bridge/), section "Differences between user-defined bridges and the default bridge". It says containers on the default bridge can only access each other by IP address, which matches my test.
