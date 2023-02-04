#!/bin/bash -ex
git submodule update --init --recursive
IMG=gabrielv/python-browser-experiments:pygbag-wasm-0.7
( time docker build . --tag $IMG ) 2>&1 | tee .docker-build.log
docker push $IMG || true
