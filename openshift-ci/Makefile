# This Makefile contains downstream fixes/updates to avoid conflicts while merging upstream changes to the original `Makefile` file.

include ./Makefile

export GOCACHE := $(PWD)/openshift-ci/.gocache
export XDG_CACHE_HOME := $(PWD)/openshift-ci/.xdg-cache

$(GOLANGCI_LINT):
	(cd /; GO111MODULE=on go get -u github.com/golangci/golangci-lint/cmd/golangci-lint@master)

.PHONY: lint
lint: test-style

.PHONY: unit
unit: test-unit
