#!/bin/sh

# FORMAT:   ./docker.sh [build | run] [Docker image tag]
# Must be run from simpleOS root dir.

if [ -z "$1" ]; then
    echo >&2 "Missing Docker command parameter ('build' or 'run')."
    exit 1
fi

if [ "$1" != "build" ] && [ "$1" != "run" ]; then
    echo >&2 "Invalid Docker command parameter (must be 'build' or 'run')"
    exit 1
fi

if [ -z "$2" ]; then
    echo >&2 "Missing Docker image tag parameter."
    exit 1
fi

# build docker container with image tag parameter at $2
function build() {

    # FLAGS:
    #   t - tag for image

    docker build  \
        env  \
        -t "$1"
}

# run docker container with image tag parameter at $2
function run() {

    # FLAGS:
    #   rm - automatically remove container on exit
    #   interactive - keep STDIN open, even if not attached
    #   tty - allocate pseudo-TTY
    #   volume - bind PWD to /root/env in container

    docker run                          \
        --rm                            \
        --interactive                   \
        --tty                           \
        --volume $(eval pwd):/root/env  \
        "$1"
}

if [ "$1" == "build" ]; then
    build "$2"
elif [ "$1" == "run" ]; then
    run "$2"
fi
