#!/usr/bin/make -f

SHELL                   := /usr/bin/env bash
REPO_NAMESPACE          ?= jamesbrink
REPO_USERNAME           ?= jamesbrink
REPO_API_URL            ?= https://hub.docker.com/v2
IMAGE_NAME              ?= fooocus
CUDA_VERSION            ?= 12.6.3
BASE_IMAGE              ?= nvidia/cuda:$(CUDA_VERSION)-runtime-ubuntu22.04
SED                     := $(shell [[ `command -v gsed` ]] && echo gsed || echo sed)
VERSION                 := v2.5.5

# Default target is to build container
.PHONY: default
default: build

# Build the docker image
.PHONY: build
build: list
	docker build \
		--build-arg BASE_IMAGE=$(BASE_IMAGE) \
		--build-arg BUILD_DATE=$(BUILD_DATE) \
		--build-arg VERSION=$(VERSION) \
		--tag $(REPO_NAMESPACE)/$(IMAGE_NAME):latest \
		--tag $(REPO_NAMESPACE)/$(IMAGE_NAME):$(VERSION) \
		--file Dockerfile .

# List built images
.PHONY: list
list:
	docker images $(REPO_NAMESPACE)/$(IMAGE_NAME) --filter "dangling=false"

# Run any tests
.PHONY: test
test:
	docker run -t $(REPO_NAMESPACE)/$(IMAGE_NAME) env | grep VERSION | grep $(VERSION)

# Push images to repo
.PHONY: push
push:
	docker push  $(REPO_NAMESPACE)/$(IMAGE_NAME):latest; \
	docker push  $(REPO_NAMESPACE)/$(IMAGE_NAME):$(VERSION);

# Remove existing images
.PHONY: clean
clean:
	docker rmi $$(docker images $(REPO_NAMESPACE)/$(IMAGE_NAME) --format="{{.Repository}}:{{.Tag}}") --force
