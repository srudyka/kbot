APP=$(shell basename $(shell git remote get-url origin))
REGISTRY=ghcr.io/${GITHUB_ACTOR}
VERSION=$(shell git describe --tags --abbrev=0)-$(shell git rev-parse --short HEAD)
TARGETOS ?= darwin #linux
#TARGETARCH ?= arm64 #amd64

format:
	gofmt -s -w ./

get:
	go get

lint:
	golint

test:
	go test -v

build: format get
	CGO_ENABLED=0 GOOS=${TARGETOS} GOARCH=${TARGETARCH} go build -v -o kbot-${TARGETOS} -ldflags "-X="github.com/${GITHUB_ACTOR}/kbot/cmd.appVersion=${VERSION}

image:
	docker build . -t ${REGISTRY}/${APP}:${VERSION}-${TARGETOS} --build-arg TARGETOS=${TARGETOS}

registry_logout:
	docker logout ghcr.io

registry_login:
	docker login ghcr.io --username ${GITHUB_ACTOR} --password ${GITHUB_TOKEN}
#	echo ${GITHUB_TOKEN} | docker login ghcr.io -u ${GITHUB_ACTOR} --password-stdin

push: registry_logout registry_login image
	docker push ${REGISTRY}/${APP}:${VERSION}-${TARGETOS}

clean:
	rm -rf kbot-*
