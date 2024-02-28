#!/bin/bash
set -e

get_toolkit_secret() {
    jq --raw-output .${1} toolkit-secrets.json
}

HOST=$(get_toolkit_secret     argocd.host)
PORT=$(get_toolkit_secret     argocd.port)
USERNAME=$(get_toolkit_secret argocd.username)
PASSWORD=$(get_toolkit_secret argocd.password)

argocd login --insecure $HOST:$PORT --username $USERNAME --password $PASSWORD
