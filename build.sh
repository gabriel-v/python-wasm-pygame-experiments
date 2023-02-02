#!/bin/bash -ex
git submodule update --init --recursive
IMG=the-ultimate-videogame-pygame-wasm:build
( docker build . --tag $IMG ) 2>&1 | tee .docker-build.log
