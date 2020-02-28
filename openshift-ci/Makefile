# This Makefile contains downstream fixes/updates to avoid conflicts while merging upstream changes to the original `Makefile` file.

include ./Makefile

export GOCACHE := $(PWD)/openshift-ci/.gocache
export XDG_CACHE_HOME := $(PWD)/openshift-ci/.xdg-cache

GOLANGCI_LINT := $(GOPATH)/bin/golangci-lint

export GOLANGCI_LINT_VERSION := 1.21.0

$(GOLANGCI_LINT):
	cd /
	curl -sSL https://github.com/golangci/golangci-lint/releases/download/v$(GOLANGCI_LINT_VERSION)/golangci-lint-$(GOLANGCI_LINT_VERSION)-linux-amd64.tar.gz | tar xz
	mv golangci-lint-$(GOLANGCI_LINT_VERSION)-linux-amd64/golangci-lint $(GOLANGCI_LINT)
	rm -rf golangci-lint-$(GOLANGCI_LINT_VERSION)-linux-amd64

.PHONY: lint
lint: $(GOLANGCI_LINT) test-style

.PHONY: unit
unit: test-unit
