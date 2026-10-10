# Docker: image vs container vs layer

Block 2 gate topic `b2#0`. Written 2026-10-08.

## Definitions
| Term | Meaning |
|---|---|
| **Layer** | One saved change to the filesystem, made by a `RUN`, `COPY` or `ADD` step. Read-only. |
| **Image** | A stack of layers. A read-only template; running it never changes it. |
| **Container** | A running copy of an image plus one thin **writable layer** on top for its own changes. |

Where a file goes when a container writes it: into that container's writable layer. It survives `docker stop` and `docker start`, and is lost when the container is deleted (`docker rm`). To keep data across deletion, use a volume (see `docker-volumes.md`).

## My experiment (2026-10-08, alpine)
```bash
export MSYS_NO_PATHCONV=1
docker run -d --name w1 alpine sleep 300
docker exec w1 sh -c "echo hi > /note.txt"
docker diff w1                      # A /note.txt
docker run -d --name w2 alpine sleep 300
docker exec w2 cat /note.txt        # No such file or directory
docker stop w1 && docker start w1
docker exec w1 cat /note.txt        # hi
docker rm -f w1 w2
```
| Check | Result |
|---|---|
| `docker diff w1` | `A /note.txt` (added in w1's writable layer) |
| `w2` reads the file | not found: each container has its own writable layer |
| `w1` after stop and start | file still there |

## Not tested here
Layers being **shared** between containers of the same image (so two containers don't each store a full copy of the image) is how Docker is designed, but I have not measured it in this project.

## Interview one-liner
"An image is a read-only stack of layers. A container is an image plus a thin writable layer on top. Files a container writes go there, so they survive a stop and start but disappear when the container is deleted."

## Official docs (checked 2026-10-09)
- [About storage drivers](https://docs.docker.com/engine/storage/drivers/), sections "Images and layers" and "Container and layers": "When the container is deleted, the writable layer is also deleted."
