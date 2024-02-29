#!/bin/bash
set -e
source config.sh

if helm list --short -n $namespace | grep -q "^$releaseName$"; then
    helm upgrade $releaseName -n $namespace --create-namespace --wait --values $valuesFile $chartPath
else
    helm install $releaseName -n $namespace --create-namespace --wait --values $valuesFile $chartPath
fi
