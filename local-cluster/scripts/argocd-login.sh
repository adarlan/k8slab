#!/bin/bash
set -ex

HOST=localhost
PORT=$(terraform output -raw argocd_port)
USERNAME=admin
PASSWORD=$(kubectl get secret argocd-initial-admin-secret -n argocd -o jsonpath='{.data.password}' | base64 --decode)

argocd login --insecure $HOST:$PORT --username $USERNAME --password $PASSWORD
