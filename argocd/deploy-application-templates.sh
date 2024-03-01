#!/bin/bash
set -ex

chartPath=application-templates
releaseName=argocd-apps
namespace=argocd

if helm list --short -n $namespace | grep -q "^$releaseName$"; then
    helm upgrade $releaseName -n $namespace --create-namespace $chartPath
else
    helm install $releaseName -n $namespace --create-namespace $chartPath
fi

# helm template $releaseName -n $namespace --values $valuesFile $chartPath > templates.manifest.yaml
