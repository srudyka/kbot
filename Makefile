APP=$(shell basename $(shell git remote get-url origin) .git)
REGISTRY=ghcr.io/${GITHUBACTOR}
VERSION=$(shell git describe --tags --abbrev=0)-$(shell git rev-parse --short HEAD)
# user is able to pass "darwin" to build binary for macOS
# but we build docekr image only for linux
TARGETOS ?= linux
TARGETARCH ?= amd64

format:
	gofmt -s -w ./

get:
	go get

lint:
	golint

test:
	go test -v

build: format get
	CGO_ENABLED=0 GOOS=${TARGETOS} GOARCH=${TARGETARCH} go build -v -o kbot -ldflags "-X="github.com/${GITHUBACTOR}/kbot/cmd.appVersion=${VERSION}

image:
	docker build . -t ${REGISTRY}/${APP}:${VERSION}-${TARGETOS}-${TARGETARCH} --build-arg TARGETOS=${TARGETOS} --build-arg TARGETARCH=${TARGETARCH}

registry_logout:
	docker logout ghcr.io

registry_login:
	docker login ghcr.io --username ${GITHUBACTOR} --password ${GITHUBTOKEN}

push: registry_logout registry_login image
	docker push ${REGISTRY}/${APP}:${VERSION}-${TARGETOS}-${TARGETARCH}

clean:
	rm -rf kbot-*
