#!/usr/bin/make -f
.ONESHELL:
.SHELLFLAGS = -e -o pipefail -u -c
SHELL := /bin/bash
MAKEFLAGS += --warn-undefined-variables

CWD := $(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))
DIR_RESOURCE := $(shell dirname $(CWD))
DIR_COMMON := $(DIR_RESOURCE)/common
DIR_LIBS := $(DIR_COMMON)/libs
APP_NAME := $(shell basename $(CWD))

OCI_CMD ?= podman## Oci exe

Q = @
ifneq ($(origin TERM),undefined)
	BLACK        := $(shell tput -Txterm setaf 0)
	RED          := $(shell tput -Txterm setaf 1)
	GREEN        := $(shell tput -Txterm setaf 2)
	YELLOW       := $(shell tput -Txterm setaf 3)
	LIGHTPURPLE  := $(shell tput -Txterm setaf 4)
	PURPLE       := $(shell tput -Txterm setaf 5)
	BLUE         := $(shell tput -Txterm setaf 6)
	WHITE        := $(shell tput -Txterm setaf 7)
	RESET        := $(shell tput -Txterm sgr0)
else
	BLACK        := ""
	RED          := ""
	GREEN        := ""
	YELLOW       := ""
	LIGHTPURPLE  := ""
	PURPLE       := ""
	BLUE         := ""
	WHITE        := ""
	RESET        := ""
endif

VENV ?= venv## Virtual env path
PYENV = . $(VENV)/bin/activate;
PYTHONPATH = PYTHONPATH="$${PYTHONPATH:-}:$(DIR_LIBS)"
PORT ?= 8000## Runtime port


ifeq ($(shell command -v column >/dev/null && echo 1 || echo 0),1)
  COLPIPE = | column -t -s $$'\t'
else
  COLPIPE =
endif

VERBOSE ?= 0## Set verbose level (0: no, 1: print target, 2: shell verbose, 3: both)

ifeq ($(VERBOSE),$(filter $(VERBOSE),2 3))
  .SHELLFLAGS = -e -o pipefail -u -x -c
endif
ifeq ($(VERBOSE),$(filter $(VERBOSE),1 3))
  Q :=
else
  Q := @
endif

TARGET = help
.PHONY: help
help:  ## Print current help documentation
	$(Q)echo -e "\n\t$(PURPLE)Makefile usage documentation$(RESET)\n"
	echo "List of main targets:"
	grep --no-filename -E '^[a-z0-9A-Z._-]+:.*?## .*$$' $(MAKEFILE_LIST) | LANG=C sort \
	    | awk 'BEGIN {FS = ":.*?## "}; {printf "$(BLUE)%s$(RESET)\t%s\n", $$1, $$2}' $(COLPIPE)
	echo
	echo "List of environment variables:"
	grep --no-filename -E '^[a-zA-Z._-]+ *\?= *[^#]*## .*$$' $(MAKEFILE_LIST) | LANG=C sort | \
	    awk 'match($$0, /([a-zA-Z._-]+) *\?= *([^#]*)## (.*)$$/, var) { \
	        printf "$(BLUE)%s$(RESET)\t$(YELLOW)%s$(RESET)\t%s\n", var[1], var[2], var[3]}' $(COLPIPE) || true
	echo
	echo "Overridden defaults:"
	grep --no-filename -E '^[a-zA-Z._-]+ *\?= *[^#]*## .*$$' $(MAKEFILE_LIST) | LANG=C sort | \
	    awk 'match($$0, /([a-zA-Z._-]+) *\?= *([^#]*)## (.*)$$/, var) { \
	    printf "%s\n", var[1]}' | while read var; do if [ -x $${!var+x} ]; then : ; else printf '"%s" => "%s"\n' "$${var}" "$${!var}"; fi; done

LOCAL ?= 0# Local exe

$(VENV): $(VENV)/touchfile

$(VENV)/touchfile: requirements.txt
	$(Q)[ -d venv ] || virtualenv venv
	$(PYENV) pip install -r $<
	touch $@

.PHONY: run
run: $(VENV)  ## Run backend
	$(Q)$(PYENV) $(PYTHONPATH) uvicorn app.main:app --reload --port $(PORT)

.PHONY: build.kaniko
build.kaniko:  ## Build container
	$(MAKE) clean
	cd $(DIR_RESOURCE)
	[ -d tmp ] || mkdir tmp
	$(OCI_CMD) run --rm -v $(DIR_RESOURCE):/workspace \
	    gcr.io/kaniko-project/executor:v1.23.1-slim --reproducible \
	    --build-arg TARGET=$(APP_NAME) \
	    --dockerfile /workspace/common/Dockerfile.kaniko --context dir:///workspace/ \
	    --no-push --tar-path tmp/image.tar.gz \
	    --destination poc-$(APP_NAME):latest \
	    --single-snapshot --snapshot-mode=time --use-new-run
	if command -v skopeo >/dev/null; then
	    skopeo copy --all --preserve-digests tarball:tmp/image.tar.gz containers-storage:localhost/poc-$(APP_NAME):latest
	else
	    $(OCI_CMD) load --input tmp/image.tar.gz
	fi
	rm tmp/image.tar.gz

.PHONY: build
build:  ## Build container
	$(MAKE) clean
	cd $(DIR_RESOURCE)
	$(OCI_CMD) build --build-arg=TARGET=$(APP_NAME) -f common/Dockerfile -t localhost/poc-$(APP_NAME) .

.PHONY: push
push:  ## Build container
	$(OCI_CMD) push --tls-verify=false localhost/poc-$(APP_NAME):latest registry.localhost:60080/poc-$(APP_NAME):latest


clean:  ## Clean temporary files
	$(Q)[ ! -d $(VENV) ] || rm -rf $(VENV)
	[ ! -d tmp ] || rm -rf tmp
	find . -iname "*.pyc" -delete
	find . -type d -name "__pycache__" -exec rm -rf {} +
