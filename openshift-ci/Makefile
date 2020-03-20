# This Makefile contains downstream fixes/updates to avoid conflicts while merging upstream changes to the original `Makefile` file.

include ./Makefile

export OPENSHIFT_CI := $(CURDIR)/openshift-ci
export GOCACHE := $(OPENSHIFT_CI)/.gocache
export XDG_CACHE_HOME := $(OPENSHIFT_CI)/.xdg-cache

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

.PHONY: acceptance
acceptance:
	CURDIR=$(CURDIR) $(OPENSHIFT_CI)/acceptance-tests.sh

.PHONY: clean-cache
clean-cache:
	rm -rf $(GOCACHE)
	rm -rf $(XDG_CACHE_HOME)
