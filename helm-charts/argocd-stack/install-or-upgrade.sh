#!/bin/bash
set -e
source config.sh

if helm list --short -n $namespace | grep -q "^$releaseName$"; then
    helm upgrade $releaseName \
        --namespace $namespace --create-namespace \
        --values $valuesFile \
        --wait \
        $chartPath
        # --dependency-update
        # --wait-for-jobs
else
    helm install $releaseName \
        --namespace $namespace --create-namespace \
        --values $valuesFile \
        --wait \
        $chartPath
        # --dependency-update
        # --wait-for-jobs
fi
