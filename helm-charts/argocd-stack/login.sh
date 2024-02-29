#!/bin/bash
set -e
source config.sh

# secrets
# NAME                                  TYPE                 DATA
# argocd-image-updater-secret           Opaque               0   
# argocd-initial-admin-secret           Opaque               1   
# argocd-notifications-secret           Opaque               0   
# argocd-secret                         Opaque               5   
# sh.helm.release.v1.{RELEASE_NAME}.v1  helm.sh/release.v1  1   

HOST=localhost
PORT=8001
USERNAME=admin
PASSWORD=$(kubectl get secret -n $namespace argocd-initial-admin-secret -o json | jq --raw-output .data.password | base64 --decode)

argocd login --insecure $HOST:$PORT --username $USERNAME --password $PASSWORD

echo "--------------------------------------------------------------------------------"
echo
echo -e "\e[1;34mARGO CD SERVER\e[0m"
echo
echo "URL:      http://$HOST:$PORT"
echo "Username: $USERNAME"
echo "Password: $PASSWORD"
echo
echo "--------------------------------------------------------------------------------"
