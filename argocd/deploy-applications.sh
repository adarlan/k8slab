#!/bin/bash
set -ex

KUBECTL_APPLYSET=true \
kubectl apply -f applications/ --prune --applyset=argocd-applications
