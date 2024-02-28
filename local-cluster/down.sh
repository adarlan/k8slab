#!/bin/bash
set -e

down() {
    # terraform_config
    # terraform_apply_config_adapter
    # terraform_destroy_kind_toolkit
    terraform_destroy_kind_cluster
    # git_clean config-adapter
    # git_clean kind-toolkit
    # git_clean kind-cluster
    # git_clean .
}

terraform_config() {
    TF_VERSION="1.7.3"
    tfenv install $TF_VERSION
    tfenv use $TF_VERSION
}

terraform_apply_config_adapter() {
    terraform -chdir=config-adapter init
    # TF_LOG="INFO" \
    terraform -chdir=config-adapter apply -var-file=./../config.tfvars -auto-approve
    terraform -chdir=config-adapter output -json kind_cluster_config > kind-cluster-config.json
    terraform -chdir=config-adapter output -json kind_toolkit_config > kind-toolkit-config.json
}

terraform_destroy_kind_toolkit() {
    terraform -chdir=kind-toolkit init
    # TF_LOG="INFO" \
    terraform -chdir=kind-toolkit destroy -var-file=./../kind-toolkit-config.json
    echo '{}' > kind-toolkit-config.json
    echo '{}' > kind-toolkit-output.json
}

terraform_destroy_kind_cluster() {
    terraform -chdir=kind-cluster init
    # TF_LOG="INFO" \
    terraform -chdir=kind-cluster destroy -var-file=./../cluster-config.json
    echo '{}' > kind-cluster-config.json
    echo '{}' > kind-cluster-output.json
}

git_clean() {
    BACK=$(pwd)
    cd $1
    git clean -Xf
    rm -rf .terraform
    cd $BACK
}

down

# source functions.sh

# undeploy-app hello-world || true
# undeploy-app python-crud || true

# terraform-config

# terraform-destroy argo-cd               || force-destroy argo-cd               || true
# terraform-destroy kube-prometheus-stack || force-destroy kube-prometheus-stack || true
# terraform-destroy ingress-nginx         || force-destroy ingress-nginx         || true
# terraform-destroy trivy-operator        || force-destroy trivy-operator        || true
# terraform-destroy loki-stack            || force-destroy loki-stack            || true

# terraform-destroy kind-toolkit
# terraform-destroy kind-cluster
#   || force-destroy kind-cluster

# git-clean argo-cd
# git-clean kube-prometheus-stack
# git-clean ingress-nginx
# git-clean trivy-operator
# git-clean kind-cluster
