#!/bin/bash
set -e
source config.sh

HOST=localhost
PORT=8001
USERNAME=admin
PASSWORD=$(kubectl get secret -n $namespace argocd-initial-admin-secret -o json | jq --raw-output .data.password | base64 --decode)

argocd login --insecure $HOST:$PORT --username $USERNAME --password $PASSWORD

echo "--------------------------------------------------------------------------------"
echo
echo -e "\e[1;34mARGOCD SERVER\e[0m"
echo
echo "URL:      http://$HOST:$PORT"
echo "Username: $USERNAME"
echo "Password: $PASSWORD"
echo
echo "--------------------------------------------------------------------------------"
