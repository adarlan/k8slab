#!/bin/bash
set -ex

KUBECTL_APPLYSET=true \
kubectl delete -f application-sets/ --applyset=argocd-application-sets
