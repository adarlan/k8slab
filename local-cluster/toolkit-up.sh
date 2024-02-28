#!/bin/bash
set -e

__main__() {
    terraform_config
    terraform_apply_kind_toolkit
}

terraform_config() {
    TF_VERSION="1.7.3"
    tfenv install $TF_VERSION
    tfenv use $TF_VERSION
}

terraform_apply_kind_toolkit() {
    terraform -chdir=kind-toolkit init
    # TF_LOG="INFO" \
    terraform -chdir=kind-toolkit apply -var-file=./../toolkit-config.json -parallelism=1
    terraform -chdir=kind-toolkit output -json secrets > toolkit-secrets.json
}

__main__
