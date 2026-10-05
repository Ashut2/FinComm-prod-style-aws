################################### Part 1 ####################################

# Docker layer cache test: product-catalog

Date: 2026-10-02
Block: 2 (Docker I), build task: layer-cache timing comparison

## Goal
Measure how much Docker's layer cache saves on `product-catalog` builds, using my own timings.

## Hypothesis (written before running)
- My Idea: If I change only `main.go`, I expect Docker to redo the compilation of code as adding a comment had nothing to do with downloading libraries(copying go.mod)


- Slowest build: the first build with --no-cache, cause everything has to be build for the first time & nothing is cached. 
- When I edit `main.go`, layers that stay `CACHED`: from gobuilder + copy go.mod & go.sum + copy flags + workdir /app + copy genproto
- When I edit `main.go`, layers that rebuild: Run CGO_ENABLED=0 + CMD 

## Setup
- Image: `fincomm/product-catalog:dev`
- Dockerfile: `docker/product-catalog/Dockerfile` (single-stage, Go 1.27.1)
- Build context: `application/product-catalog`
- Run from the repo root.

## Method
Three builds, in order, each timed with `time`:

1. Cold build, no cache:
   ```bash
   time docker build --no-cache --progress=plain -f docker/product-catalog/Dockerfile -t fincomm/product-catalog:dev application/product-catalog
   ```
2. Rebuild with nothing changed:
   ```bash
   time docker build --progress=plain -f docker/product-catalog/Dockerfile -t fincomm/product-catalog:dev application/product-catalog
   ```
3. Rebuild after appending a comment to `main.go`:
   ```bash
   echo "// cache test" >> application/product-catalog/main.go
   time docker build --progress=plain -f docker/product-catalog/Dockerfile -t fincomm/product-catalog:dev application/product-catalog
   ```
4. Cleanup: `git checkout -- application/product-catalog/main.go`

## Results

| Build | Real time | Steps marked CACHED | Steps rebuilt |
|---|---|---|---|
| 1. Cold (`--no-cache`) |1m42.605s |2(workdir /app) | 3,4,5 (30s), 6,7,8,9|
| 2. Nothing changed |3.760s | 7,2,3,4,8,5,6,9| none |
| 3. After editing `main.go` |28.057s | 2,4,6,5,3,7 | 8(COPY `*.go`) & 9(compile,24s)|

## Observations
- Which step took the most time in the cold build, and why?
compilation of the program `RUN CGO_ENABLED.....` took max time cause it was the first compilation, this step generated plain linux binary with no c dependencies. and it saves it at the root of the filesystem (/). doing all of this obviously will eat more time than others. (Close second: `go mod download` took 29.8s, compile took 32.4s.)

- In build 3, did the `go mod download` step stay cached? Why?
In build 3 there has been no change in the copying of go libraries that are needed to run *.go files. so when we changed the main.go file it doesn't effect the copying of library & pluging of it into our ecosystem. 

But what have changed is the main.go file itself so compilation of that file is needed again.
Hence `go mod download` step stay cached & `RUN CGO_ENABLED=...` is rebuilt

- Was my hypothesis right? What did I get wrong?
It was almost right up to the point. things I got wrong is just the step i forgot that would be rebuilt after `main.go` would be edited.  so writing them again here 

- the steps which be rebuilt again 
    - 8 : copy `*.go`,   it copies all go files 
    - 9 : compile , it compiles all the copied go files. 

## Conclusion
I would give me conclusion in following points:

- I came to an understanding of this idea that the instruction Dockerfile have, each acts as a separate layer. Docker saves each step's result and reuses it (this is `caching`) if that step and everything above it are unchanged.

- When nothing is cached, it takes the longest time, & after one build, some steps get cached cause nothing changed there

- after editing `main.go` file, the step which involves copying & compiling the file would always get rebuilt whenever we edit it. 

- My numbers: cold build 102.6s vs unchanged 3.76s, so cached was about 27x faster. A one-line `main.go` edit took 28.06s, about 3.7x faster than cold (saved about 75s).

- The rule: when one step changes, every step after it re-runs. So slow steps that rarely change (like `go mod download`) go at the top of the Dockerfile, and fast steps that change often (like copying source code) go at the bottom.

## Link to later work
Block 3 (multi-stage build): compare the image size (1.35 GB single-stage) and the build behaviour against this baseline.

################################# Part 2 #######################################

Date: 2026-10-05

## layer map from `docker history`
```text
docker history --format "table {{.CreatedBy}}\t{{.Size}}" fincomm/product-catalog:dev
CREATED BY                                      SIZE
CMD ["/plain-linux-binary"]                     0B
EXPOSE [3550/tcp]                               0B
RUN /bin/sh -c CGO_ENABLED=0 GOOS=linux go b…   350MB
COPY *.go ./ # buildkit                         19.4kB
COPY flags flags # buildkit                     2.7kB
COPY genproto/oteldemo genproto/oteldemo # b…   140kB
RUN /bin/sh -c go mod download # buildkit       158MB
COPY go.sum go.sum # buildkit                   17.6kB
COPY go.mod go.mod # buildkit                   4.52kB
WORKDIR /app                                    0B
WORKDIR /go                                     0B
RUN /bin/sh -c mkdir -p "$GOPATH/src" "$GOPA…   0B
COPY /target/ / # buildkit                      244MB
ENV PATH=/go/bin:/usr/local/go/bin:/usr/loca…   0B
ENV GOPATH=/go                                  0B
ENV GOTOOLCHAIN=local                           0B
ENV GOLANG_VERSION=1.27.1                       0B
RUN /bin/sh -c set -eux;  apt-get update;  a…   259MB
RUN /bin/sh -c set -eux;  apt-get update;  a…   177MB
RUN /bin/sh -c set -eux;  apt-get update;  a…   48.4MB
# debian.sh --arch 'amd64' out/ 'bookworm' '…   117MB
```

One takeaway: my image is 1.35GB but the program is 32 mb only.
Go files needs only one executable file to run go programs & nothing else, the 350 MB compile layer is only a 32 MB program plus about 315 MB of Go's build cache (checked with `du` inside the image). 

NOTE: Build times change a little from run to run, even when nothing in the Dockerfile changed. For example, the compile step took 24s in one build and 40s in another. So the exact seconds in this doc are rough. What I can rely on is the direction (a cached build is faster, and a bad instruction order is slower), not the exact number of seconds.

## Bad order experiment
| Dockerfile order | Rebuild after a one-line edit | `go mod download` |
|---|---|---|
| Good (libraries first) | 28.06s | CACHED |
| Bad (source first) | 55.0s | re-ran |

`Note:` this experiment proved that changing the order of source code copying & libraries copying results in different build time. In the bad build I moved the three source `COPY` lines above `RUN go mod download`. After a one-line edit, `COPY *.go` changed, so every step after it re-ran, including `go mod download`, which stayed CACHED in the good order. The rebuild took 55.0s instead of 28.06s (about 27s slower). 




