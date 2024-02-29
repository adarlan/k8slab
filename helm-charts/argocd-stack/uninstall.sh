#!/bin/bash
set -e
source config.sh

helm uninstall $releaseName -n $namespace --wait

kubectl delete crd \
    applications.argoproj.io \
    applicationsets.argoproj.io \
    appprojects.argoproj.io
