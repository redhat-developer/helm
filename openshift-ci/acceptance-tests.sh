#!/bin/bash

export CURDIR="${CURDIR:-$(dirname $(readlink -f $0))}"
export ACCEPTANCE_DIR="${ACCEPTANCE_DIR:-$(readlink -f $CURDIR/../acceptance-testing)}"

if [ -z "$1" ]; then
    TARGETS=linux/amd64 make build
    HELM_PATH="$(readlink -f $CURDIR/../bin)"
else
    HELM_PATH="$1"
fi

if [ ! -d $ACCEPTANCE_DIR ]; then 
    git clone --depth=1 https://github.com/ldimaggi/acceptance-testing.git $ACCEPTANCE_DIR; 
else
    cd $ACCEPTANCE_DIR;
    git reset --hard;
    git pull;
fi

ROBOT_RUN_TESTS=repos.robot \
ROBOT_HELM_V3=1 \
ROBOT_DEBUG_LEVEL=3 \
ROBOT_HELM_PATH="$HELM_PATH" \
make -f $ACCEPTANCE_DIR/Makefile acceptance
