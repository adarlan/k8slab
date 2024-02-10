#!/bin/bash
set -e

echo "Creating local environment"
export TF_LOG=INFO
terraform init
terraform apply

echo "Exporting kubeconfig file"
terraform output kubeconfig > kubeconfig
sed -i '1s/^<<EOT$//' kubeconfig
sed -i '${/^EOT$/d;}' kubeconfig
mv kubeconfig ~/.kube/config

echo "Interacting with the cluster"
kubectl cluster-info

# -----------

echo "Waiting until Nginx Ingress is ready to process requests"
kubectl wait --namespace ingress-nginx \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/component=controller \
  --timeout=90s

# -----------

echo "Exposing the Argo CD API server"
kubectl port-forward svc/argocd-server -n argocd 8080:443 > /dev/null 2>&1 &
sleep 5

echo "Adding the cluster to Argo CD"
ARGOCD_PASSWORD=$(kubectl get secret argocd-initial-admin-secret -n argocd -o jsonpath='{.data.password}' | base64 --decode)
CONTEXT_CLUSTER=$(kubectl config get-contexts -o name)
argocd login --insecure localhost:8080 --username admin --password $ARGOCD_PASSWORD
argocd cluster add $CONTEXT_CLUSTER -y --in-cluster

echo "Creating Argo CD applications"
kubectl apply -f ./../../argocd-apps/argocd-apps.yaml

echo "Open Argo CD UI in your browser"
echo "URL: https://127.0.0.1:8080"
echo "Username: admin"
echo "Password: $ARGOCD_PASSWORD"

echo "Syncing hello-world application and exposing its service"
argocd app sync hello-world
kubectl port-forward svc/hello-world 8081:8080 -n hello-world > /dev/null 2>&1 &
echo "URL: https://127.0.0.1:8081"
