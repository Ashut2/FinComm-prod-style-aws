# syntax=docker/dockerfile:1 
### A comment telling docker which version of the Dockerfile 'language' to use. It doesnt build anything!

FROM golang:1.27.1-bookworm AS builder

### start from already-made image that already has Go 1.27.1 installed on Debian ("bookworm"). the long @sha.. locks it to one exact image, so it can never silently change. This stage is nicknamed `builder`

### Set destination for COPY
WORKDIR /app
### this is the new folder we created inside the image, after this everything happens inside this foler of the image. 

### Download Go modules

COPY go.mod go.mod
COPY go.sum go.sum
### it means copy content of go.sum file & name it go.sum inside the image /app

### COPY ./docker/product-catalog/go.mod go.mod -> It would make sense if i build from my repo root, 
### COPY ./docker/product-catalog/go.sum go.sum -> but as our source code sits with this dockerfile & inside this folder we just need to copy go.mod & go.sum for now 

RUN go mod download

### Copy the source code. Note the slash at the end, as explained in
### https://docs.docker.com/engine/reference/builder/#copy


COPY genproto/oteldemo genproto/oteldemo
COPY flags flags
COPY *.go ./
### left side mean "every file ending in .go, sitting next to Dockerfile". The right side means "Put them in the current folder ", which is our `WORKDIR`



### Build

RUN CGO_ENABLED=0 GOOS=linux go build -o /plain-linux-binary 
### compiles the program | cgo_enabled=0 goos=linux are the settings for that command, telling it "build plain linux binary with zero dependency on C library". `-o /plain-linux-binary` names the resulting file plain-linux-binary and places it at the root of the image's filesystem (/). 

EXPOSE 3550
### it just for documentation, telling readers that this app listens on port 8080. It doesn't open the port & doesn't check whether the program really uses 8080. 

### Run
CMD ["/plain-linux-binary"]
