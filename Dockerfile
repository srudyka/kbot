FROM golang:1.25 as builder
ARG TARGETOS
WORKDIR /go/src/app
COPY . .
RUN make build

FROM scratch
ARG TARGETOS
WORKDIR /
COPY --from=builder /go/src/app/kbot-${TARGETOS} .
COPY --from=alpine:latest /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
ENTRYPOINT ["./kbot-${TARGETOS}"]
