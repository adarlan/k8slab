#!/bin/bash
set -e

printf "\nConfiguring kubectl\n"
cp ./kubeconfig ~/.kube/config
# TODO merge and use context instead of replacing

kubectl cluster-info

exit 0

CLUSTER_NAME = $(terraform output -raw cluster_name)
CLUSTER_ENDPOINT = $(terraform output -raw cluster_endpoint)

terraform output -raw cluster_ca_certificate > ca.crt

kubectl config set-cluster $CLUSTER_NAME --server=$CLUSTER_ENDPOINT \
  --certificate-authority=ca.crt --embed-certs=true
