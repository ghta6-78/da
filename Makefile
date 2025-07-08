PROJECT_DIR := $(shell pwd)

COMMIT=$(shell git rev-parse --short HEAD)
DATE=$(shell date -u '+%Y-%m-%d')
# A basic dev tag is by default so that the same image is rebuilt during development
VERSION?=dev

# Setup the full image name
IMAGE_REPO?=ghcr.io/mirantiscontainers
IMAGE_NAME?=mke-operator

# Get the currently used golang install path (in GOPATH/bin, unless GOBIN is set)
ifeq (,$(shell go env GOBIN))
GOBIN=$(shell go env GOPATH)/bin
else
GOBIN=$(shell go env GOBIN)
endif

# primarily to ensure we can test on mac after installing findutils and gsed
FIND=gfind
ifeq (, $(shell which gfind))
FIND=find
endif

SED=gsed
ifeq (, $(shell which gsed))
SED=sed
endif

# CONTAINER_TOOL defines the container tool to be used for building images.
# Be aware that the target commands are only tested with Docker which is
# scaffolded by default. However, you might want to replace it to use other
# tools. (i.e. podman)
CONTAINER_TOOL ?= docker

# Setting SHELL to bash allows bash commands to be executed by recipes.
# Options are set to exit when a recipe line exits non-zero or a piped command fails.
SHELL = /usr/bin/env bash -o pipefail
.SHELLFLAGS = -ec

.PHONY: all-charts-paths
all-charts-paths:
	@echo '['| tr -d '\n' && ${FIND} charts -name Chart.yaml -printf '"%h", ' | ${SED} 's/, $$//' && echo ']'

.PHONY: print-%
print-%:
	@echo $($*)
