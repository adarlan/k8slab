#!/bin/bash
set -e

echo "Creating local environment"
export TF_LOG=INFO
terraform init
terraform apply

echo "Copying kubeconfig file to ~/.kube/config"
cp kubeconfig ~/.kube/config

echo "Interacting with the cluster"
kubectl cluster-info

echo "Exposing Argo CD server"
kubectl port-forward svc/argocd-server -n argocd 8080:443 > /dev/null 2>&1 &
sleep 5

echo "Adding the cluster to Argo CD"
ARGOCD_PASSWORD=$(kubectl get secret argocd-initial-admin-secret -n argocd -o jsonpath='{.data.password}' | base64 --decode)
CONTEXT_CLUSTER=$(kubectl config get-contexts -o name)
argocd login --insecure localhost:8080 --username admin --password $ARGOCD_PASSWORD
argocd cluster add $CONTEXT_CLUSTER -y --in-cluster

echo "Creating Argo CD applications"
kubectl apply -f ./../argocd-apps

echo "Syncing Argo CD applications"
argocd app sync --project default

echo "Exposing hello-world application"
kubectl port-forward svc/hello-world 8081:8080 -n hello-world > /dev/null 2>&1 &
