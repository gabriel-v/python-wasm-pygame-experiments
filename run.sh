#!/bin/bash -e
IMG=gabrielv/python-browser-experiments:pygbag-wasm-0.7.2
mkdir -p .cache/docker-.cache
docker run --name pygame-server-experiments-wasm --user "`id -u`:`id -g`" --rm -it \
    -p 127.0.0.1:8000:8000 \
    -p 127.0.0.1:8080:8080 \
    -v "$PWD:/mount"  \
    -v "$PWD/.cache/docker-.cache:/.cache" \
    -w '/mount' \
    --entrypoint "/bin/bash" --hostname videogame \
    $IMG -c "./in-container.sh"
    # $IMG -c "pygbag --bind 0.0.0.0  $1"
