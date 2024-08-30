# This Makefile contains downstream fixes/updates to avoid conflicts while merging upstream changes to the original `Makefile` file.

include ./Makefile

export GOCACHE := $(PWD)/openshift-ci/.gocache
export XDG_CACHE_HOME := $(PWD)/openshift-ci/.xdg-cache

export ACCEPTANCE_DIR := $(CURDIR)/acceptance-testing
export ACCEPTANCE_RUN_TESTS := repos.robot
export ROBOT_HELM_V3 := 1
export ROBOT_DEBUG_LEVEL := 3
export ROBOT_RUN_TESTS=.
export ROBOT_HELM_PATH=/usr/bin
export ROBOT_OPTS=--xunit=results.xml


.PHONY: test-completion
test-completion: test-acceptance-completion