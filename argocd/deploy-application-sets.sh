#!/bin/bash
set -ex

KUBECTL_APPLYSET=true \
kubectl apply -f application-sets/ --prune --applyset=argocd-application-sets
