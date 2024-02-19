#!/bin/bash
set -ex

CLUSTER_NAME=$(terraform output -raw cluster_name)
CLUSTER_ENDPOINT=$(terraform output -raw cluster_endpoint)
USER_NAME=${CLUSTER_NAME}
CONTEXT_NAME=$USER_NAME

terraform output -raw cluster_ca_certificate > ca.crt
terraform output -raw client_key             > client.key
terraform output -raw client_certificate     > client.crt

kubectl config set-cluster     $CLUSTER_NAME --server=$CLUSTER_ENDPOINT --certificate-authority=ca.crt --embed-certs=true
kubectl config set-credentials $USER_NAME    --client-key=client.key --client-certificate=client.crt --embed-certs=true
kubectl config set-context     $CONTEXT_NAME --user=$USER_NAME --cluster=$CLUSTER_NAME

kubectl config use-context $CONTEXT_NAME
kubectl cluster-info

exit 0

KUBECONFIG=kubeconfig:~/.kube/config kubectl config view --merge --flatten > ~/.kube/config
