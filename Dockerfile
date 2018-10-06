# Stage 1. Build the binary
FROM golang:1.11

# add a non-privileged user
RUN useradd -u 10001 myapp

RUN mkdir -p /go/src/github.com/ngeorgieva/go-sofia-workshop
ADD . /go/src/github.com/ngeorgieva/go-sofia-workshop
WORKDIR /go/src/github.com/ngeorgieva/go-sofia-workshop

# build the binary with go build
RUN go get ./... && CGO_ENABLED=0 go build \
	-o bin/go-sofia-workshop github.com/ngeorgieva/go-sofia-workshop/cmd/go-sofia-workshop

# Stage 2. Run the binary
FROM scratch

ENV PORT 8080
ENV DIAG_PORT 3000

COPY --from=0 /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/

COPY --from=0 /etc/passwd /etc/passwd
USER myapp

COPY --from=0 /go/src/github.com/ngeorgieva/go-sofia-workshop/bin/go-sofia-workshop /go-sofia-workshop
EXPOSE $PORT
EXPOSE $DIAG_PORT


CMD ["/go-sofia-workshop"]