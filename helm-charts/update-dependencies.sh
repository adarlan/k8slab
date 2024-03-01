#!/bin/bash
set -e

for chartPath in */; do
    if [ -d "$chartPath" ]; then
        cd $chartPath
        helm dependency update
        cd -
    fi
done
