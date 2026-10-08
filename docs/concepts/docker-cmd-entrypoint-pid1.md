# Docker: CMD vs ENTRYPOINT, and PID 1 on `docker stop`

Block 2 gate topic `b2#4`. Written 2026-10-08. All results below were run on this machine (Docker engine 29.8.0, Docker Desktop, alpine images).

## CMD vs ENTRYPOINT
- **CMD** is a *default* command. Anything typed after the image name in `docker run` **replaces** it.
- **ENTRYPOINT** is the *fixed program*. Anything typed after the image name is **added to it** as arguments. It is replaced only with `--entrypoint`.
- If both are set, CMD supplies the default arguments to the ENTRYPOINT.

Test: two tiny images, one with `ENTRYPOINT ["echo","entry"]` + `CMD ["default"]`, one with only `CMD ["echo","cmd-default"]`.

| Command | Output |
|---|---|
| ENTRYPOINT + CMD image, no args | `entry default` |
| same image, arg `custom` | `entry custom` (arg appended, entrypoint kept) |
| same image, `--entrypoint echo ... replaced` | `replaced` |
| CMD-only image, no args | `cmd-default` |
| CMD-only image, `echo override` | `override` (CMD replaced) |

In this project: my `product-catalog` Dockerfile uses `CMD ["/plain-linux-binary"]`; the OpenTelemetry demo's uses `ENTRYPOINT`. When I ran `docker run ... fincomm/product-catalog:dev du -sh ...` on 5 Oct, the `du` command replaced the CMD, which is why the service did not start.

## PID 1 and `docker stop`
The program a container starts becomes **PID 1**. `docker stop` sends it SIGTERM ("please shut down"); if it has not exited when the grace period ends, Docker sends SIGKILL (force kill). PID 1 gets no default signal handling, so a program that doesn't install its own SIGTERM handler (like `sleep`) ignores the polite signal.

| Test (`alpine sleep 300`) | `docker stop` time | Exit code |
|---|---|---|
| `sleep` as PID 1 (`docker exec p1 ps` showed `1 root sleep 300`) | about 3.4-3.5 s | **137** |
| same, `docker stop -t 10` | about 10.5 s | 137 |
| with `--init` (`/sbin/docker-init` as PID 1, forwards signals) | about 0.56 s | **143** |

Reading the results:
- **137 = 128 + 9** (SIGKILL): the program didn't exit on SIGTERM and was force-killed.
- **143 = 128 + 15** (SIGTERM): the program shut down when asked, i.e. gracefully.
- **Correction to my own expectation:** I predicted a plain `docker stop` would take about 10 s. On this Docker version it took about 3.5 s, while `-t 10` took about 10.5 s, so the default grace period here is shorter than 10 s. I did not find out why; the rule that matters (kill after the grace period, exit code 137) held.

## Not tested
How `product-catalog` itself behaves on `docker stop` (graceful 143 or forced 137) is unknown. A quick check: run the container, `docker stop` it, read `.State.ExitCode`.

## Interview one-liner
"CMD is a default that `docker run` arguments replace; ENTRYPOINT is the fixed program and arguments are appended. The container's main program is PID 1: `docker stop` sends SIGTERM and then SIGKILL after the grace period, and the exit code tells which happened, 143 for a graceful stop and 137 for a forced kill."
