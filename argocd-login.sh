#!/bin/bash
set -e

kubectl port-forward svc/argocd-server -n argocd 8080:443 > /dev/null 2>&1 &
sleep 5
ARGOCD_PASSWORD=$(kubectl get secret argocd-initial-admin-secret -n argocd -o jsonpath='{.data.password}' | base64 --decode)
argocd login --insecure localhost:8080 --username admin --password $ARGOCD_PASSWORD

# argocd cluster add $(kubectl config get-contexts -o name) -y --in-cluster
