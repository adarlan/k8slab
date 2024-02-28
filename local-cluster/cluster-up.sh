#!/bin/bash
set -e

__main__() {
    terraform_config
    terraform_apply_kind_cluster
}

terraform_config() {
    TF_VERSION="1.7.3"
    tfenv install $TF_VERSION
    tfenv use $TF_VERSION
}

terraform_apply_kind_cluster() {
    terraform -chdir=kind-cluster init
    # TF_LOG="INFO" \
    terraform -chdir=kind-cluster apply -var-file=./../cluster-config.json
    terraform -chdir=kind-cluster output -json secrets > cluster-secrets.json
}

__main__
