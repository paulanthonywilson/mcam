#!/usr/bin/env bash

set -e


SCRIPT_PATH=`dirname $0`
BASE_PATH=`realpath "$SCRIPT_PATH/.."`
DOCKER_PATH="$BASE_PATH/docker_build"

BUILD_CACHE=$BASE_PATH/rel/build_cache/
WORKDIR=/home/asdf/build

mkdir -p $BASE_PATH/rel/artefacts
mkdir -p $BUILD_CACHE/_build
mkdir -p $BUILD_CACHE/deps



docker build -t mcam -f $DOCKER_PATH/Dockerfile --build-arg USER_ID=$(id -u) --build-arg GROUP_ID=$(id -g) .

docker run \
    -v $BASE_PATH/rel/artefacts:/home/asdf/artefacts \
    -v $BUILD_CACHE/_build:$WORKDIR/_build \
    -v $BUILD_CACHE/deps:$WORKDIR/deps  \
    --rm -it mcam $WORKDIR/docker_build/build
