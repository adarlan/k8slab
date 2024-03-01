#!/bin/bash
set -e

for chartPath in */; do
    if [ -d "$chartPath" ]; then

        chartName=$(basename $chartPath)
        releaseName=$chartName
        namespace=$releaseName
        valuesFile=$chartName/values.yaml
        manifestFile=$releaseName.manifest.yaml

        (
            set -ex
            helm template $releaseName $chartPath -n $namespace --values $valuesFile > $manifestFile
        )
    fi
done
