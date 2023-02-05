#!/bin/bash -e
IMG=gabrielv/python-browser-experiments:pygbag-wasm-0.7.2
mkdir -p .cache/docker-.cache
docker run \
    --rm -it \
    --name pygame-server-experiments-wasm \
    --user "`id -u`:`id -g`" \
    -p 127.0.0.1:8000:8000 \
    -v "$PWD:/mount"  \
    -w '/mount' \
    --hostname videogame \
    --entrypoint /bin/bash \
    $IMG -c "/mount/in-container.sh"
