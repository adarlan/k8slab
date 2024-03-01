#!/bin/bash
set -e

releaseName=argocd-apps
namespace=argocd

helm uninstall $releaseName -n $namespace
