#!/bin/bash
set -e

for manifestFile in *.manifest.yaml; do
    if [ -f "$manifestFile" ]; then

        namespace="${manifestFile%%.*}"

        if kubectl get namespace $namespace > /dev/null 2>&1; then
            (
                set -ex
                kubectl delete -f $manifestFile -n $namespace
                kubectl delete namespace $namespace
            )
        fi

        rm $manifestFile
    fi
done
