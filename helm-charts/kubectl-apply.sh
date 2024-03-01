#!/bin/bash
set -e

namespace=$1
manifestFile=$1.manifest.yaml

kubectl create namespace $namespace --dry-run=client -o yaml | kubectl apply -f -
kubectl apply -f $manifestFile -n $namespace
