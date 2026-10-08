# Block 2 recall and gap check (2026-10-08)

Blank-page recall of container networking, layer caching and volumes, checked against my own notes and measurements. Concept notes: `docs/concepts/docker-networking.md`, `docker-layer-caching.md`, `docker-volumes.md`.

## Result by topic
| Topic | What I said | Correction or gap | Status |
|---|---|---|---|
| Networking | Containers on the default bridge are "isolated"; a user-defined network gives DNS | Default bridge is not isolated: it lacks **name lookup** (`bad address`), and containers should still reach each other by IP. Missing: `-p` is for traffic from outside, `host.docker.internal` is for a container reaching the laptop | verified 2026-10-08: ping by IP works, by name fails |
| Networking (experiment) | Four containers, A/B on a dedicated network worked, C/D on the default bridge did not | Right, but should say the failure was name resolution, and quote the evidence (172.19.0.3 resolved; `bad address 'box-d'`) | fixed in the concept note |
| Layer caching | Each statement is a layer; unchanged layers are reused; stable steps on top | "Each statement" is only true for `RUN`/`COPY`/`ADD` (`EXPOSE`/`CMD` are 0 B). Missing the key rule (a changed layer re-runs everything **after** it) and my measured numbers | fixed in the concept note |
| Volumes | Storage outside the container; data in a container is lost on deletion | Correct. Add that stop/start keeps data and only deletion loses it, add the experiment result, and note Postgres is native for now | fixed in the concept note |

## What I forgot and had to look up
- That a volume experiment was done at all (5 Oct, `docs/notes/docker-volume-test.md`).
- The layer-cache numbers (102.6 s / 3.76 s / 28.06 s / 55.0 s).
- Lesson: reread the experiment notes before a recall, and quote the numbers.

## Block 2 gate: still to cover
The gate needs all five questions scored, with no zero. Recall covered three topics partially. Not yet covered:
- `b2#0` Image vs container vs layer: what is read-only and what is not. Studied and tested 2026-10-08, see `docs/concepts/docker-images-containers-layers.md` (score it yourself in the tracker).
- `b2#4` `CMD` vs `ENTRYPOINT`, and what happens to PID 1 on `docker stop`. Studied and tested 2026-10-08, see `docs/concepts/docker-cmd-entrypoint-pid1.md` (score it yourself in the tracker).

Only `b2#2` (how container A finds container B by name) is scored in the tracker so far. Scoring is mine to do, honestly, after studying these.

## Next
1. Done: default-bridge test run and recorded in `docker-networking.md`.
2. Study `b2#0` and `b2#4`, then score the gate.
