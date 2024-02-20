#!/bin/bash
set -ex

with-helm() {
    helm install hello-world ../helm-charts/hello-world
}

with-argocd() {
    kubectl apply -f ../argocd-apps
}
