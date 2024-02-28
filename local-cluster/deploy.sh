#!/bin/bash
set -e

__main__() {
    deploy_app_with_helm_template_and_kubectl_apply python-crud
}

apply_argocd_apps() {
    kubectl apply -f ../argocd-apps/${1}.yaml
}

deploy_app_with_helm_template_and_kubectl_apply() {

    chartPath=../helm-charts/${1}
    releaseName=${1}
    valuesFile=deploy-config.json
    manifestsFile=${1}-manifests.yaml
    namespace=${1}

    helm template $releaseName $chartPath -n $namespace --values $valuesFile > $manifestsFile

    kubectl create namespace $namespace --dry-run=client -o yaml | kubectl apply -f -
    kubectl apply -f $manifestsFile -n $namespace
}

__main__
