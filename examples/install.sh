#!/bin/bash -ex
for line in $(cat ./repos.txt); do
  git submodule add $line
done
