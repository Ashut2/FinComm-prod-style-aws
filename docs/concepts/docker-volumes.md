# Docker volumes

Block 2 concept note. Written 2026-10-08 after the blank-page recall. Full experiment: `docs/notes/docker-volume-test.md`.

## The idea
A container's own storage is disposable: it lives in a thin writable layer on top of the read-only image. **Deleting** the container deletes that layer and the data in it. A **volume** is a storage area Docker keeps outside the container, so the data survives when the container is deleted and a new container can use it.

Nuance: stopping and starting a container keeps its data. Deleting (`docker rm`) or recreating it loses data that was not on a volume.

## What my experiment showed (5 Oct 2026, alpine)
| Case | Result |
|---|---|
| Volume `fincomm-vol`: container A wrote a file, A was deleted, a new container read the volume | file was still there |
| No volume: container wrote `/tmp/note.txt`, was deleted, a new container looked for it | `No such file or directory` |

Lesson from the run: two typos in `MSYS_NO_PATHCONV` made a path-rewriting problem look like data loss. Check typos and environment before doubting the concept.

## This project today
Postgres runs **natively on the laptop**, not in a container, so its data is not on a Docker volume yet. The real database-on-a-volume setup comes with Compose in Block 3.

## Interview one-liner
"Data written inside a container is lost when the container is deleted. A named volume lives outside the container, so a database keeps its data across container restarts and replacements."

## Official docs (checked 2026-10-09)
- [Volumes](https://docs.docker.com/engine/storage/volumes/), section "When to use volumes" (volumes are the preferred way to persist container data) and section "A volume's lifecycle" (data outlives the container).
