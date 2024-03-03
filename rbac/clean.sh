#!/bin/bash
set -e

clean() {

  kubectl config set-context kind-k8slab --namespace default
  kubectl config use-context kind-k8slab

  (

    set +e

    kubectl delete rolebinding developer-johndev -n dev
    kubectl delete csr johndev
    kubectl delete role developer -n dev
    kubectl delete namespace dev

    kubectl delete clusterrolebinding administrator-janeops
    kubectl delete csr janeops
    kubectl delete clusterrole administrator

    set -e
  ) 2>/dev/null

  git clean -Xfd
}

clean
