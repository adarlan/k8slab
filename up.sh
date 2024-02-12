#!/bin/bash
set -e

cd local-environment

echo "Creating local environment"
export TF_LOG=INFO
terraform init
terraform apply -auto-approve

echo "Copying kubeconfig file to ~/.kube/config"
cp kubeconfig ~/.kube/config

echo "Interacting with the cluster"
kubectl cluster-info

echo "Exposing Argo CD server"
kubectl port-forward svc/argocd-server -n argocd 8080:443 > /dev/null 2>&1 &
sleep 5
# TODO instead of sleep, wait until argo-cd server is ready

echo "Logging into Argo CD server"
ARGOCD_PASSWORD=$(kubectl get secret argocd-initial-admin-secret -n argocd -o jsonpath='{.data.password}' | base64 --decode)
argocd login --insecure localhost:8080 --username admin --password $ARGOCD_PASSWORD

echo "Adding the cluster to Argo CD"
argocd cluster add $(kubectl config get-contexts -o name) -y --in-cluster

echo "Creating Argo CD applications"
kubectl apply -f ./../argocd-apps

echo "Syncing Argo CD applications"
argocd app sync --project default
