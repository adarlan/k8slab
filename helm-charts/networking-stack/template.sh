#!/bin/bash
set -e
source config.sh

helm template $releaseName -n $namespace --values $valuesFile $chartPath > manifest.yaml
