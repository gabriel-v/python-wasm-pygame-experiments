#!/bin/bash -e
IMG=the-ultimate-videogame-pygame-wasm:build
mkdir -p .cache/docker-.cache
docker run --user "`id -u`:`id -g`" --rm -it \
    -p 127.0.0.1:8000:8000 \
    -v "$PWD:/mount"  \
    -v "$PWD/.cache/docker-.cache:/.cache" \
    -w '/mount' \
    --entrypoint "/bin/bash" --hostname videogame \
    $IMG -c "./in-container.sh"
    # $IMG -c "pygbag --bind 0.0.0.0  $1"
