FROM golang:1.25 as builder
ARG TARGETOS
ARG TARGETARCH
WORKDIR /go/src/app
COPY . .
RUN make build TARGETOS=${TARGETOS} TARGETARCH=${TARGETARCH}

FROM alpine:latest as certs
RUN apk --update add ca-certificates

FROM scratch
WORKDIR /
COPY --from=builder /go/src/app/kbot /kbot
COPY --from=certs /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
ENTRYPOINT ["/kbot"]
