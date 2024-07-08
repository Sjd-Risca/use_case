#!/usr/bin/make -f
.ONESHELL:
.SHELLFLAGS = -e -o pipefail -u -c
SHELL := /bin/bash
MAKEFLAGS += --warn-undefined-variables

CWD := $(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))
ROOT := $(shell dirname $(CWD))

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


NIX := nix --extra-experimental-features nix-command --extra-experimental-features
BUILD_PATH := iso_build
DISK := root.qcow2
DISK_PATH := $(BUILD_PATH)/$(DISK)

$(DISK_PATH): $(wildcard $(BUILD_PATH)/*)
	pushd "$$(dirname $@)"
	$(NIX) flakes build .#nixosConfigurations.build-qcow2.config.system.build.qcow2
	cp result/nixos.qcow2 $(DISK)
	popd
	chmod 644 $@

.PHONY: build
build:  $(DISK_PATH) ## Build qcow2 image

.PHONY: run
run: $(DISK_PATH)  ## Run virtual machine locally on KVM
	echo "Local FS available at:"
	echo "mount -t 9p poc /poc"
	kvm -name nixos -m 6G -smp 2 \
	    -drive cache=writeback,file=$<,id=drive1,if=none,index=1,werror=report \
	    -device virtio-blk-pci,bootindex=1,drive=drive1 \
	    -nic user,hostfwd=tcp::60022-:22,hostfwd=tcp::60080-:80 \
	    -virtfs local,path=$(ROOT),mount_tag=poc,security_model=mapped-xattr \
	    -nographic

.PHONY: ssh
ssh:
	ssh -o "GlobalKnownHostsFile /dev/null" -o "UserKnownHostsFile /dev/null" demo@127.0.0.1 -p 60022

