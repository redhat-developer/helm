# This Makefile contains downstream fixes/updates to avoid conflicts while merging upstream changes to the original `Makefile` file.

include ./Makefile

export GOCACHE := $(PWD)/openshift-ci/.gocache
export XDG_CACHE_HOME := $(PWD)/openshift-ci/.xdg-cache

export GOLANGCI_LINT_VERSION := 1.21.0

export ACCEPTANCE_DIR := $(CURDIR)/acceptance-testing
export ACCEPTANCE_RUN_TESTS := repos.robot
export ROBOT_HELM_V3 := 1
export ROBOT_DEBUG_LEVEL := 3

ifdef BINDIR
	export BINDIR := $(shell echo $$BINDIR)
	export DO_NOT_BUILD_HELM := 1
endif

ifndef BINDIR
	export BINDIR := $(CURDIR)/bin
	export DO_NOT_BUILD_HELM := 0
endif

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
ifeq ($(DO_NOT_BUILD_HELM), 1)
acceptance:
else
acceptance: TARGETS = linux/amd64
acceptance: build build-cross
endif
	@if [ -d "${ACCEPTANCE_DIR}" ]; then \
		cd ${ACCEPTANCE_DIR} && \
			ROBOT_RUN_TESTS=$(ACCEPTANCE_RUN_TESTS) ROBOT_HELM_PATH=$(BINDIR) make acceptance; \
	else \
		echo "You must clone the acceptance_testing repo under $(ACCEPTANCE_DIR)"; \
		echo "You can find the acceptance_testing repo at https://github.com/helm/acceptance-testing"; \
	fi
