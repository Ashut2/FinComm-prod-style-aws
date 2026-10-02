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
compilation of the program `RUN CGO_ENABLED.....` took max time cause it was the first compilation, this step generated plain linux binary with no c Dependenies. and it saves it at the root of the filesystem (/). doing all of this obviously will eat more time than others.

- In build 3, did the `go mod download` step stay cached? Why?
In build 3 there has been no change in the copying of go liraries that are needed to run *.go files. so when we changed the main.go file it doesn't effect the copying of library & pluging of it into our ecosystem. 

But what have changed is the main.go file itself so compilation of that file is needed again.
Hence `go mod download` step stay cached & `RUN CGO_ENABLED=...` is rebuilt

- Was my hypothesis right? What did I get wrong?
It was almost right upto the point. things I got wrong is just the step i forgot that would be rebuilt after `main.go` would be edited.  so writing them again here 

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
