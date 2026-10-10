# Docker layer caching

Block 2 concept note. Written 2026-10-08 after the blank-page recall. Full experiment: `docs/notes/docker-layer-cache-test.md`.

## The idea
A Dockerfile is a list of steps. Docker saves the result of each step and **reuses it if that step and everything above it are unchanged**. Once one step changes, **every step after it runs again**.

Only `RUN`, `COPY` and `ADD` create real layers. `EXPOSE`, `CMD` and `ENV` are metadata (0 B in `docker history`).

Rule of thumb: put steps that rarely change (installing dependencies) at the top, and steps that change often (copying source code) at the bottom.

## My measured numbers (product-catalog, Go, single-stage image)
| Build | Real time | What ran |
|---|---|---|
| Cold, `--no-cache` (2 Oct) | 102.6 s | everything (library download ~30 s, compile ~32 s) |
| Nothing changed (2 Oct) | 3.76 s | nothing, all steps reused |
| After a one-line `main.go` edit (2 Oct) | 28.06 s | `COPY *.go` and the compile (~24 s); download reused |
| Same edit, source copied **before** the download (5 Oct) | 55.0 s | download re-ran too |

Timings vary between runs (the compile step took 24 s to 66 s on identical work), so say "about". The direction is reliable, the exact seconds are not.

## Interview answer (about 30 seconds)
"Docker saves each Dockerfile step's result and reuses it if that step and everything above it are unchanged. I measured it on a Go service: a cold build took 102.6 seconds, an unchanged rebuild 3.8 seconds, and a one-line code edit 28 seconds, because only copying and compiling re-ran while the 30-second library download stayed cached. When I deliberately copied the source before the download, the same edit took 55 seconds, because the download re-ran every time. So dependencies go at the top."

## What is inside the image (preview of Block 3)
- The image is 1.35 GB, but the compiled program is only **32 MB**.
- The 350 MB compile layer is the 32 MB program plus about 315 MB of Go's build cache.
- The base golang image layers are about 845 MB (about 62%); my own layers are about 508 MB (about 38%).
- A multi-stage build ships only the program. That shrinks a Go service a lot, but a Python or Node service must still ship its interpreter, so it shrinks much less.
- The "after" size of the multi-stage image is not measured yet. Record it in `docs/impact/impact-log.md` when it is.

## Official docs (checked 2026-10-09)
- [Build cache](https://docs.docker.com/build/cache/), section "How the build cache works": "If a layer changes, all other layers that come after it are also affected." This is the rule behind my numbers.
- [Optimize build cache](https://docs.docker.com/build/cache/optimize/), section "Order your layers": the instruction-ordering advice.
