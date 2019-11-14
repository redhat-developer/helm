# This Makefile.redhat contains downstream fixes/updates to avoid conflicts while merging upstream changes to the original `Makefile` file.

include ./Makefile

$(GOLANGCI_LINT):
	(cd /; GO111MODULE=on go get -u github.com/golangci/golangci-lint/cmd/golangci-lint@master)

.PHONY: lint
lint: test-style
