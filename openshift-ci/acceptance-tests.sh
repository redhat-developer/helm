#!/bin/bash

# Copyright The Helm Authors.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

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
