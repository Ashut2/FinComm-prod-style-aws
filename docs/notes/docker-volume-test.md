# Docker volume test: does data survive a deleted container?

Date: 2026-10-05
Block: 2 (Docker I), build task: named volume test

## Goal
Show that data written to a named volume survives when the container is deleted, and that data written inside a container without a volume does not.

## Predictions (write BEFORE running)
- Part A, container B reads the file after container A was deleted: Yes it can read as data is written into the volume fincomm-vol

- Part B, a new container reads the file after the first container was deleted (no volume): in case of `no-volume` the container consist all the data, once it is deleted, everything is gone. 

## Setup
- Image: `alpine` (tiny throwaway Linux, nothing to do with the project)
- Volume name: `fincomm-vol`
- Git Bash rewrites Linux-style paths like `/data`, so every `docker run` below starts with `MSYS_NO_PATHCONV=1`.

## Part A: with a volume
```bash
docker volume create fincomm-vol
MSYS_NO_PATHCONV=1 docker run --rm -v fincomm-vol:/data alpine sh -c "echo hello from container A > /data/note.txt && cat /data/note.txt"
docker ps -a
MSYS_NO_PATHCONV=1 docker run --rm -v fincomm-vol:/data alpine cat /data/note.txt
```

## Part B: without a volume
```bash
docker run --name vol-c alpine sh -c "echo temp > /tmp/note.txt"
docker rm vol-c
MSYS_NO_PATHCONV=1 docker run --rm alpine cat /tmp/note.txt
```

## Cleanup
```bash
docker volume rm fincomm-vol
```

## Results
| Part | What printed | Was my prediction right? |
|---|---|---|
| A (volume) |`hello from container A` | yes |
| B (no volume) |`can't open /tmp/note.txt` | yes |

## Observations
- Why did the file survive in Part A?
file survive in part A because before container A was deleted, the data is stored in a storage area that Docker manages outside the container, the `fincomm-vol` volume. hence deleting container have no effect on the data until volume is also deleted for clean-up process during this experiment. 

- Why was the file gone in Part B?
file gone in part B because it was written into that container's own writable layer (a thin layer on top of the read-only alpine image; the image itself is not changed). When the container is deleted, that layer is deleted with it, so the file is gone too.

- What does `--rm` do, and why did it not delete the data in Part A?
`--rm` flag is used to delete the container automatically when it exits. It did not deleted the data in part A cause its data was safely stored in `fincomm-vol:/data`


## What went wrong during my real run
- On the write step I forgot `--rm`, so container A stayed behind as "Exited". I deleted it by hand with `docker rm <id>` (the `rm` command, not the `--rm` flag). Same result as `--rm`.
- On the read step I typed the variable name wrong (`MSYS_NO_PATHCONv`, lowercase v). Git Bash rewrote `/data/note.txt` into `C:/Program Files/Git/data/note.txt`, and `cat` said "can't open". That looked like data loss but was a path-rewriting problem, not a volume problem. After setting `export MSYS_NO_PATHCONV=1` and rerunning, the file was read correctly.
- Lesson: when a result contradicts what you expect, check for a typo or environment cause before concluding the concept is wrong.

## Conclusion
(In my own words: where does a database's data need to live, and why?)

A database data needs to live in docker Volumes because data written inside a container is lost whenever that container is deleted or recreated, but a volume keeps the data intact. 
And a database is only reliable & usable if its data is consistent & does not vanish after refresh or deletion of any particular container. 

## Link to later work
Block 3 (Compose): Postgres will run in a container on a named volume. Native Postgres on this machine is why this test uses alpine for now.
