#!/bin/bash
set -ex

KUBECTL_APPLYSET=true \
kubectl delete -f applications/ --applyset=argocd-applications
